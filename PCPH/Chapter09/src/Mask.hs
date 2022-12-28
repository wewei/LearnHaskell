module Mask
    ( modifyMVar_
    , modifyMVar
    , casMVar
    , modifyTwo
    , forkFinally
    ) where

import Control.Concurrent ( MVar, takeMVar, putMVar, ThreadId, forkIO )
import Control.Exception ( try, mask, catch, throw, SomeException )

modifyMVar_ :: MVar a -> (a -> IO a)  -> IO ()
modifyMVar_ m f = mask $ \restore -> do
    v <- takeMVar m
    u <- restore (f v) `catch` \e -> do putMVar m v; throw (e :: SomeException)
    putMVar m u
    
modifyMVar :: MVar a -> (a -> IO (a, b)) -> IO b
modifyMVar m f = mask $ \restore -> do
    v      <- takeMVar m
    (u, b) <- restore (f v) `catch` \e -> do putMVar m v; throw (e :: SomeException)
    putMVar m u
    return b

casMVar :: Eq a => MVar a -> a -> a -> IO Bool
casMVar m old new = modifyMVar m $ \val -> do
    if val == old
        then return (new, True)
        else return (val, False)

modifyTwo :: MVar a -> MVar b -> (a -> b -> IO (a, b)) -> IO ()
modifyTwo ma mb f = modifyMVar_ mb $ modifyMVar  ma . flip f

forkFinally :: IO a -> (Either SomeException a -> IO ()) -> IO ThreadId
forkFinally action fun = mask $ \restore -> forkIO $ do
    r <- try (restore action)
    fun r