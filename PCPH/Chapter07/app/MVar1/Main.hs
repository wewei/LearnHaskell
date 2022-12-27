module Main (main) where

import Control.Concurrent
    ( forkIO, newEmptyMVar, putMVar, takeMVar )

main :: IO ()
main = do
    m <- newEmptyMVar
    _ <- forkIO $ putMVar m 'x'
    r <- takeMVar m
    print r