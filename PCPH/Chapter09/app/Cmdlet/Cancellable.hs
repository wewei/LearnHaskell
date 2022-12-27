module Cmdlet.Cancellable ( run ) where

import System.IO ( hSetBuffering, stdin, BufferMode(NoBuffering) )
import Control.Concurrent ( forkIO )
import Control.Monad ( forever, when )
import Data.Either ( rights )
import Text.Printf ( printf )

import Data ( sites )
import Async ( async, waitCatch, cancel )
import TimeDownload ( timeDownload )

run :: IO ()
run = do
    as <- mapM (async . timeDownload) sites
    _  <- forkIO $ do
        hSetBuffering stdin NoBuffering
        forever $ do
            c <- getChar
            when (c == 'q')  $ mapM_ cancel as

    rs <- mapM waitCatch as
    printf "%d/%d succeeded\n" (length (rights rs)) (length rs)