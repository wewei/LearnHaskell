module Async
    ( Async
    , async
    , waitCatch
    , wait
    , waitEither
    , waitAny
    , cancel ) where

import Control.Exception
    ( SomeException
    , AsyncException(ThreadKilled)
    , throwIO )

import Control.Concurrent
    ( MVar
    , ThreadId
    , newEmptyMVar
    , putMVar
    , readMVar
    , throwTo )

import Mask ( forkFinally )

data Async a = Async [ThreadId] (MVar (Either SomeException a))

async :: IO a -> IO (Async a)
async action = do
    var <- newEmptyMVar
    tid <- forkFinally action $ putMVar var
    return (Async [tid] var)

waitCatch :: Async a -> IO (Either SomeException a)
waitCatch (Async _ var) = readMVar var

wait :: Async a -> IO a
wait a = do
    r <- waitCatch a
    case r of
        Left e  -> throwIO e
        Right v -> return v

waitEither :: Async a -> Async b -> IO (Either a b)
waitEither a b = do
    m    <- newEmptyMVar
    tid1 <- forkFinally (fmap Left  (wait a)) (putMVar m)
    tid2 <- forkFinally (fmap Right (wait b)) (putMVar m)
    wait (Async [tid1, tid2] m)

waitAny :: [Async a] -> IO a
waitAny as = do
    m <- newEmptyMVar
    let forkwait a = forkFinally (wait a) (putMVar m)
    tids <- mapM forkwait as
    wait (Async tids m)

cancel :: Async a -> IO ()
cancel (Async tids _) = mapM_ (`throwTo` ThreadKilled) tids
