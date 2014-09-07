{-# LANGUAGE DeriveDataTypeable #-}
module Language.Haskell.GHC.ExactPrint.Types
  (
    Comment(..)
  , Pos
  , PosToken
  , DeltaPos(..)
  , Annotation(..)
  , AnnSpecific(..)
  , annNone
  , Anns(..)
  ) where

import Data.Data

import qualified Bag           as GHC
import qualified DynFlags      as GHC
import qualified FastString    as GHC
import qualified ForeignCall   as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified Lexer         as GHC
import qualified Name          as GHC
import qualified NameSet       as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
import qualified StringBuffer  as GHC
import qualified UniqSet       as GHC
import qualified Unique        as GHC
import qualified Var           as GHC

import qualified Data.Map as Map

-- | A Haskell comment. The 'Bool' is 'True' if the comment is multi-line, i.e. @{- -}@.
data Comment = Comment Bool GHC.SrcSpan String
  deriving (Eq,Show,Typeable,Data)
-- ++AZ++ : Will need to convert output of getRichTokenStream to Comment

-- getRichTokenStream :: GhcMonad m => Module -> m [(Located Token, String)]

type PosToken = (GHC.Located GHC.Token, String)

type Pos = (Int,Int)

newtype DeltaPos = DP (Int,Int) deriving Show

annNone = Ann [] (DP (0,0)) AnnNone

data Annotation = Ann
  { ann_comments :: ![Comment]
  , ann_loc      :: !DeltaPos
  , ann_specific :: !AnnSpecific
  } deriving (Show)

data AnnSpecific =
  AnnModuleName
    { mn_module :: !DeltaPos -- module
    , mn_name   :: !DeltaPos -- Language.Haskell.GHC.Types
    , mn_op     :: !DeltaPos -- '('
    , mn_cp     :: !DeltaPos -- ')'
    , mn_where  :: !DeltaPos -- where
    }

  -- IE variants, *preceding* comma
  | AnnIEVar      { ie_comma :: !(Maybe DeltaPos) }
  | AnnIEThingAbs { ie_comma :: !(Maybe DeltaPos) }
  | AnnIEThingAll
  | AnnIEThingWith
  | AnnIEModuleContents
  | AnnIEGroup
  | AnnIEDoc
  | AnnIEDocNamed

{-
IEVar name
IEThingAbs name
IEThingAll name
IEThingWith name [name]
IEModuleContents ModuleName
IEGroup Int HsDocString
IEDoc HsDocString
IEDocNamed String

-}
  | AnnNone
  deriving (Show)

type Anns = Map.Map GHC.SrcSpan Annotation

