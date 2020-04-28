
(ns app.comp.barcode
  (:require [hsl.core :refer [hsl]]
            [respo-ui.core :as ui]
            [respo.core :refer [defcomp defeffect >> <> div button textarea span input img]]
            [respo.comp.space :refer [=<]]
            [reel.comp.reel :refer [comp-reel]]
            [respo-md.comp.md :refer [comp-md]]
            [app.config :refer [dev?]]
            ["qrcode" :as qrcode]
            ["jsbarcode" :as jsbarcode]
            [respo-alerts.comp.container :refer [use-modal-menu]]
            [respo-alerts.core :refer [comp-select]]))

(def barcodes-list
  [{:value :code-128, :display "CODE128"} {:value :gs1-128, :display "GS1-128"}])

(defeffect
 effect-render-code
 (code format)
 (action el)
 (when (or (= action :mount) (= action :update))
   (-> code
       qrcode/toDataURL
       (.then
        (fn [url]
          (-> el (.querySelector "img") (.setAttribute "src" url))
          (jsbarcode
           (-> el (.querySelector "img"))
           code
           (clj->js
            (merge
             {:displayValue false}
             (case format
               :gs1-128 {:format "CODE128", :ean128 true}
               :code-128 {:format "CODE128"}
               (do nil)))))))
       (.catch
        (fn [error]
          (js/console.error error)
          (-> el (.querySelector "img") (.setAttribute "src" ""))
          (-> el (.querySelector "img") (.setAttribute "alt" "Failed to render")))))))

(defcomp
 comp-barcode
 (states code code-data)
 [(effect-render-code code (:barcode-format code-data))
  (div
   {:style ui/center}
   (comp-select
    (>> states :format)
    (or (:barcode-format code-data) :code-128)
    barcodes-list
    {}
    (fn [result d!]
      (if (some? result) (d! :code-format {:id (:id code-data), :format result}))))
   (div {} (img {})))])
