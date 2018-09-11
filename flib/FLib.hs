{-# LANGUAGE DataKinds                #-}
{-# LANGUAGE FlexibleContexts         #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE GADTs                    #-}
{-# LANGUAGE QuasiQuotes              #-}
{-# LANGUAGE OverloadedStrings        #-}


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
-- import Data.Emacs.Module.SymbolName.TH
import Data.Emacs.Module.SymbolName


foreign export ccall initialise :: Ptr Runtime -> IO CBool


true, false :: CBool
true  = CBool 1
false = CBool 0


initialise'
  :: (WithCallStack, Throws EmacsThrow, Throws EmacsError, Throws EmacsInternalError)
  => EmacsM s Bool
initialise' = do
  -- bindFunction [esym|foo-string|]
  bindFunction (mkSymbolName . C8.pack $ "foo-string")
    =<< (makeFunction fooString "returns a string.")
  pure True


fooString :: (WithCallStack, MonadEmacs m, Monad (m s))
  => EmacsFunction 'Z 'Z 'False s m
fooString Stop = do
  produceRef =<< makeString "foo returns string"


initialise :: WithCallStack => Ptr Runtime -> IO CBool
initialise runtime = do
  runtime' <- Runtime.validateRuntime runtime
  case runtime' of
    Nothing        -> pure false
    Just runtime'' -> do
      env <- Runtime.getEnvironment runtime''
      res <- reportAllErrorsToEmacs env (pure False) $ runEmacsM env initialise'
      pure $ if res then true else false

