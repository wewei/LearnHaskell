module Async
    ( Async
    , async
    , waitCatch
    , wait
    , waitEither
    , waitAny ) where

import Control.Exception ( SomeException, try, throwIO )
import Control.Concurrent (MVar, newEmptyMVar, putMVar, readMVar, forkIO)

newtype Async a = Async (MVar (Either SomeException a))

async :: IO a -> IO (Async a)
async action = do
    var <- newEmptyMVar
    _ <- forkIO $ do
        r <- try action
        putMVar var r
    return (Async var)

waitCatch :: Async a -> IO (Either SomeException a)
waitCatch (Async var) = readMVar var

wait :: Async a -> IO a
wait a = do
    r <- waitCatch a
    case r of
        Left e  -> throwIO e
        Right v -> return v

waitEither :: Async a -> Async b -> IO (Either a b)
waitEither a b = do
    m <- newEmptyMVar
    _ <- forkIO $ do r <- try (fmap Left  (wait a)); putMVar m r
    _ <- forkIO $ do r <- try (fmap Right (wait b)); putMVar m r
    wait (Async m)

waitAny :: [Async a] -> IO a
waitAny as = do
    m <- newEmptyMVar
    let forkwait a = forkIO $ do r <- try (wait a); putMVar m r
    mapM_ forkwait as
    wait (Async m)