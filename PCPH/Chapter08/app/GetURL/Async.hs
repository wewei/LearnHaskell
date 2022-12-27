module Async
    ( Async
    , async
    , waitCatch
    , wait ) where

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

