
(ns app.comp.qrcode
  (:require [hsl.core :refer [hsl]]
            [respo-ui.core :as ui]
            [respo.core :refer [defcomp cursor-> <> div button textarea span input img]]
            [respo.comp.space :refer [=<]]
            [reel.comp.reel :refer [comp-reel]]
            [respo-md.comp.md :refer [comp-md]]
            [app.config :refer [dev?]]
            ["qrcode" :as qrcode]))

(defcomp comp-qrcode (code url) (div {} (img {:src url})))
