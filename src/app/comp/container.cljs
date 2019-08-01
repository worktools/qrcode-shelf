
(ns app.comp.container
  (:require [hsl.core :refer [hsl]]
            [respo-ui.core :as ui]
            [respo.core :refer [defcomp cursor-> list-> <> div button textarea span input]]
            [respo.comp.space :refer [=<]]
            [respo.comp.inspect :refer [comp-inspect]]
            [reel.comp.reel :refer [comp-reel]]
            [respo-md.comp.md :refer [comp-md]]
            [app.config :refer [dev?]]
            [feather.core :refer [comp-icon comp-i]]
            [respo-alerts.comp.alerts :refer [comp-prompt comp-confirm]]
            [clojure.string :as string]
            [app.comp.qrcode :refer [comp-qrcode]]
            ["qrcode" :as qrcode]))

(def style-card
  {:padding "12px 12px",
   :font-size 18,
   :font-family ui/font-code,
   :cursor :pointer,
   :border-bottom (str "1px solid " (hsl 0 0 88)),
   :text-overflow :ellipsis,
   :overflow :hidden})

(defcomp
 comp-container
 (reel)
 (let [store (:store reel), states (:states store)]
   (div
    {:style (merge ui/global ui/fullscreen ui/row)}
    (list->
     {:style {:background-color (hsl 0 0 96), :width 300}}
     (concat
      (->> (:codes store)
           vals
           (sort-by (fn [code] (- 0 (:time code))))
           (map
            (fn [code]
              [(:id code)
               (div
                {:style (merge
                         style-card
                         (if (= (:id code) (:pointer store)) {:background-color :white})),
                 :on-click (fn [e d! m!]
                   (d! :pointer (:id code))
                   (-> (:code code)
                       qrcode/toDataURL
                       (.then (fn [url] (d! :add-code-url url)))
                       (.catch (fn [error] (js/console.error error)))))}
                (<> (:code code)))])))
      [["create"
        (div
         {:style (merge ui/center {:padding 16})}
         (cursor->
          :create
          comp-prompt
          states
          {:trigger (comp-i :plus-square 20 (hsl 200 80 80)),
           :text "Add new code",
           :button-text "Render"}
          (fn [result d! m!] (when-not (string/blank? result) (d! :add-code result)))))]]))
    (if (some? (:pointer store))
      (div
       {:style (merge ui/expand ui/column)}
       (div
        {:style (merge ui/row-parted {:padding 8})}
        (span nil)
        (comp-icon
         :arrow-up
         {:font-size 20, :color (hsl 200 80 80), :cursor :pointer}
         (fn [e d! m!] (d! :touch-code (:pointer store)))))
       (div
        {:style (merge ui/expand ui/center)}
        (comp-qrcode (get-in store [:codes (:pointer store) :code]) (get store :code-url)))
       (div
        {:style (merge ui/row-parted {:padding 16})}
        (span nil)
        (cursor->
         :remove
         comp-confirm
         states
         {:trigger (comp-i :x-circle 20 (hsl 0 80 70))}
         (fn [e d! m!] (d! :remove-code (:pointer store))))))
      (div
       {:style (merge
                ui/expand
                ui/center
                {:font-family ui/font-fancy, :font-size 24, :color (hsl 0 0 80)})}
       (<> "No selection")))
    (when dev? (cursor-> :reel comp-reel states reel {}))
    (when dev? (comp-inspect "store" store {:bottom 0})))))
