module Cmdlet.Cancellable ( run ) where

import System.IO ( hSetBuffering, stdin, BufferMode(NoBuffering) )
import Control.Concurrent ( forkIO )
import Control.Monad ( forever, when )
import Control.Exception ( try, SomeException )
import Data.Either ( rights, isRight )
import Text.Printf ( printf )

import Data ( sites )
import Async ( async, waitCatch, cancel, waitAny )
import TimeDownload ( timeDownload )

run :: IO ()
run = do
    as <- mapM (async . timeDownload) sites
    _  <- forkIO $ do
        hSetBuffering stdin NoBuffering
        forever $ do
            c <- getChar
            when (c == 'q')  $ do
                putStrLn "Cancelling ..."
                mapM_ cancel as

    r <- (try $ waitAny as :: IO (Either SomeException ()))
    when (isRight r) $ putStrLn "First page downloaded"

    rs <- mapM waitCatch as
    putStrLn "Download finished."
    printf "%d/%d succeeded\n" (length (rights rs)) (length rs)