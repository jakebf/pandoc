{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Tests.Readers.Markdown (tests) where

import Text.Pandoc.Definition
import Test.Framework
import Tests.Helpers
import Tests.Arbitrary()
import Text.Pandoc.Builder
import Text.Pandoc

markdown :: String -> Pandoc
markdown = readMarkdown defaultParserState{ stateStandalone = True }

infix 5 =:
(=:) :: ToString c
     => String -> (String, c) -> Test
(=:) = test markdown

tests :: [Test]
tests = [ testGroup "inline code"
          [ "with attribute" =:
            "`document.write(\"Hello\");`{.javascript}"
            =?> para
                (codeWith ("",["javascript"],[]) "document.write(\"Hello\");")
          , "with attribute space" =:
            "`*` {.haskell .special x=\"7\"}"
            =?> para (codeWith ("",["haskell","special"],[("x","7")]) "*")
          ]
        , testGroup "footnotes"
          [ "indent followed by newline and flush-left text" =:
            "[^1]\n\n[^1]: my note\n\n     \nnot in note\n"
            =?> para (note (para "my note")) +++ para "not in note"
          , "indent followed by newline and indented text" =:
            "[^1]\n\n[^1]: my note\n     \n    in note\n"
            =?> para (note (para "my note" +++ para "in note"))
          ]
        ]