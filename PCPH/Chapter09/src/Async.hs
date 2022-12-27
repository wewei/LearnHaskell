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
    , try
    , throwIO )

import Control.Concurrent
    ( MVar
    , ThreadId
    , newEmptyMVar
    , putMVar
    , readMVar
    , forkIO
    , throwTo )

data Async a = Async [ThreadId] (MVar (Either SomeException a))

async :: IO a -> IO (Async a)
async action = do
    var <- newEmptyMVar
    tid <- forkIO $ do
        r <- try action
        putMVar var r
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
    tid1 <- forkIO $ do r <- try (fmap Left  (wait a)); putMVar m r
    tid2 <- forkIO $ do r <- try (fmap Right (wait b)); putMVar m r
    wait (Async [tid1, tid2] m)

waitAny :: [Async a] -> IO a
waitAny as = do
    m <- newEmptyMVar
    let forkwait a = forkIO $ do r <- try (wait a); putMVar m r
    tids <- mapM forkwait as
    wait (Async tids m)

cancel :: Async a -> IO ()
cancel (Async tids _) = mapM_ (`throwTo` ThreadKilled) tids
