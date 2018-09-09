{-# LANGUAGE DataKinds                #-}
{-# LANGUAGE FlexibleContexts         #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE GADTs                    #-}
{-# LANGUAGE QuasiQuotes              #-}


module FLib where


import Foreign
import Foreign.C
import Data.Emacs.Module.Runtime (Runtime)
import qualified Data.Emacs.Module.Runtime as Runtime
import Emacs.Module
import Emacs.Module.Assert
import Emacs.Module.Errors
import Data.ByteString.Char8 as C8

-- Bug: If we use template haskell, somehow it messes up foreign export.
import Data.Emacs.Module.SymbolName.TH
-- import Data.Emacs.Module.SymbolName

foreign export ccall someFuncfromFlib :: IO ()
foreign export ccall initialise :: Ptr Runtime -> IO CBool


someFuncfromFlib :: IO ()
someFuncfromFlib = print "foo"


true, false :: CBool
true  = CBool 1
false = CBool 0


initialise :: WithCallStack => Ptr Runtime -> IO CBool
initialise runtime = do
  runtime' <- Runtime.validateRuntime runtime
  case runtime' of
    Nothing        -> pure false
    Just runtime'' -> do
      env <- Runtime.getEnvironment runtime''
      _ <- reportAllErrorsToEmacs env (pure False)
             -- $ runEmacsM env (provide (mkSymbolName . C8.pack $ "foo") >> pure False)
             $ runEmacsM env (provide [esym|foo|] >> pure False)
      pure false
