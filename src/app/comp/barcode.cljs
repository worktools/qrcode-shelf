
(ns app.comp.barcode
  (:require [hsl.core :refer [hsl]]
            [respo-ui.core :as ui]
            [respo.core
             :refer
             [defcomp defeffect cursor-> <> div button textarea span input img]]
            [respo.comp.space :refer [=<]]
            [reel.comp.reel :refer [comp-reel]]
            [respo-md.comp.md :refer [comp-md]]
            [app.config :refer [dev?]]
            ["qrcode" :as qrcode]
            ["jsbarcode" :as jsbarcode]))

(defeffect
 effect-render-code
 (code)
 (action el)
 (when (or (= action :mount) (= action :update))
   (-> code
       qrcode/toDataURL
       (.then
        (fn [url]
          (-> el (.querySelector "img") (.setAttribute "src" url))
          (jsbarcode (-> el (.querySelector "img")) code (clj->js {}))))
       (.catch (fn [error] (js/console.error error))))))

(defcomp comp-barcode (code) [(effect-render-code code) (div {} (img {}))])
