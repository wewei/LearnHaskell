module Main ( main ) where

import Control.Concurrent
    ( forkIO, newEmptyMVar, putMVar, takeMVar )

main :: IO ()
main = do
    m <- newEmptyMVar
    _ <- forkIO $ do putMVar m 'x'; putMVar m 'y'
    r1 <- takeMVar m
    print r1
    r2 <- takeMVar m
    print r2