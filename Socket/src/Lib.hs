module Lib
    ( runServer
    ) where

import Network.Socket
    ( Socket,
      socketToHandle,
      setSocketOption,
      accept,
      bind,
      listen,
      socket,
      tupleToHostAddress,
      SocketOption(ReuseAddr),
      Family(AF_INET),
      PortNumber,
      SockAddr(SockAddrInet),
      SocketType(Stream) )

import System.IO
    ( hSetBuffering
    , hGetLine
    , hPutStrLn
    , hClose
    , BufferMode(NoBuffering)
    , IOMode(ReadWriteMode) )

import Control.Concurrent ( forkIO, killThread )
import Control.Concurrent.Chan ( Chan, writeChan, readChan, dupChan, newChan )
import Control.Monad.Fix ( fix )
import Control.Monad ( when )
import Control.Exception

type Msg = (Int, String)

runServer :: PortNumber ->  IO ()
runServer port = do
    sock <- socket AF_INET Stream 0
    setSocketOption sock ReuseAddr 1
    bind sock (SockAddrInet port $ tupleToHostAddress (0, 0, 0, 0))
    listen sock 2
    chan <- newChan
    _ <- forkIO $ fix $ \loop -> do
        _ <- readChan chan
        loop
    mainLoop sock chan 0

mainLoop :: Socket -> Chan Msg -> Int -> IO ()
mainLoop sock chan msgNum = do
    conn <- accept sock
    _ <- forkIO (runConn conn chan msgNum)
    mainLoop sock chan $! msgNum + 1

runConn :: (Socket, SockAddr) -> Chan Msg -> Int -> IO ()
runConn (sock, _) chan msgNum = do
    let broadcast msg = writeChan chan (msgNum, msg)
    hdl <- socketToHandle sock ReadWriteMode
    let send = hPutStrLn hdl
    hSetBuffering hdl NoBuffering

    send "Hi, what's your name?"
    name <- fmap init (hGetLine hdl)
    broadcast $ "--> " <> name <> " entered chat."
    send $ "Welcome, " <> name <> "!"

    commLine <- dupChan chan

    reader <- forkIO $ fix $ \loop -> do
        (nextNum, line) <- readChan commLine
        when (msgNum /= nextNum) $ send line
        loop

    handle (\(SomeException _) -> return ()) $ fix $ \loop -> do
        line <- fmap init (hGetLine hdl)
        case line of
            "quit" -> send "Bye!"
            _      -> broadcast (name <> ": " <> line) >> loop

    killThread reader
    broadcast $ "<-- " <> name <> " left."
    hClose hdl


