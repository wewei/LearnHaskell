module Logger
    ( Logger
    , initLogger
    , logMessage
    , logStop
    ) where

import Control.Monad.Fix ( fix )
import Control.Concurrent
    ( forkIO, newEmptyMVar, putMVar, takeMVar, MVar )

newtype Logger = Logger (MVar LogCommand)
data LogCommand
    = Message String
    | Stop (MVar ()) -- The parameter is used to confirm when logger is stopped

initLogger :: IO Logger
initLogger = do
    m <- newEmptyMVar
    let l = Logger m
    _ <- forkIO (logger l)
    return l

logger :: Logger -> IO ()
logger (Logger m) = fix $ \loop -> do
    cmd  <- takeMVar m
    case cmd of
        Message msg -> do
            putStrLn msg
            loop
        Stop s -> do
            putStrLn "logger: stop"
            putMVar s ()

logMessage :: Logger -> String -> IO ()
logMessage (Logger m) s = putMVar m (Message s)

logStop :: Logger -> IO ()
logStop (Logger m) = do
    s <- newEmptyMVar
    putMVar m (Stop s)
    takeMVar s
