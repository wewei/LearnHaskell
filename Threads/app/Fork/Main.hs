module Main (main) where

import Control.Concurrent ( forkIO )
import Control.Monad ( replicateM_ )
import System.IO ( hSetBuffering, stdout, BufferMode(NoBuffering) )

main :: IO ()
main = do
    hSetBuffering stdout NoBuffering
    _ <- forkIO (replicateM_ 100000 (putChar 'A'))
    replicateM_ 100000 (putChar 'B')
