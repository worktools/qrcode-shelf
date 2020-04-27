
(ns app.comp.container
  (:require [hsl.core :refer [hsl]]
            [respo-ui.core :as ui]
            [respo.core
             :refer
             [defcomp defeffect >> list-> <> div button textarea span input]]
            [respo.comp.space :refer [=<]]
            [respo.comp.inspect :refer [comp-inspect]]
            [reel.comp.reel :refer [comp-reel]]
            [respo-md.comp.md :refer [comp-md]]
            [app.config :refer [dev?]]
            [feather.core :refer [comp-icon comp-i]]
            [respo-alerts.core :refer [comp-prompt comp-confirm]]
            [clojure.string :as string]
            [app.comp.qrcode :refer [comp-qrcode]]
            [app.comp.barcode :refer [comp-barcode]]
            ["qrcode" :as qrcode]
            [applied-science.js-interop :as j]))

(defcomp
 comp-note
 (states code)
 (div
  {:style ui/row-middle}
  (<> (or (:note code) "...") {:color (hsl 0 0 70)})
  (=< 8 nil)
  (comp-prompt
   (>> states :create)
   {:trigger (comp-i :edit 14 (hsl 0 0 80)),
    :text "Some note:",
    :button-text "Add",
    :initial (:note code)}
   (fn [result d! m!]
     (d! :note-code {:id (:id code), :note (if (string/blank? result) nil result)})))))

(def style-card
  {:padding "12px 12px",
   :font-size 18,
   :font-family ui/font-code,
   :cursor :pointer,
   :border-bottom (str "1px solid " (hsl 0 0 88)),
   :text-overflow :ellipsis,
   :overflow :hidden,
   :min-width 60,
   :height 120,
   :display :inline-block})

(defcomp
 comp-sidebar
 (states store)
 (div
  {:style (merge
           ui/expand
           {:background-color (hsl 0 0 96), :display :flex, :padding "10px 60px"})}
  (list->
   {:style (merge {:margin :auto, :white-space :nowrap}), :class-name "scroll-area"}
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
              :on-click (fn [e d! m!] (d! :pointer (:id code)))}
             (div
              {}
              (<> (:code code) {:font-size 16, :line-height "40px", :display :inline-block}))
             (div
              {}
              (<>
               (:note code)
               {:color (hsl 0 0 80), :font-family ui/font-normal, :font-size 12}))
             (div {} (if (:barcode? code) (comp-i :bar-chart 16 (hsl 0 0 0)))))]))))))

(defeffect
 effect-layout
 ()
 (action el)
 (comment
  when
  (< js/window.innerWidth 800)
  (set! (-> el .-style .-flexDirection) "column")
  (set! (-> el .-style .-flexDirection) "column-reverse")
  (set! (-> el .-firstElementChild .-style .-maxWidth) "800px")
  (js/console.log (-> el .-style .-maxWidth .-firstElementChild) el)))

(defcomp
 comp-container
 (reel)
 (let [store (:store reel), states (:states store)]
   [(effect-layout)
    (div
     {:style (merge ui/global ui/fullscreen ui/column)}
     (if (some? (:pointer store))
       (div
        {:style (merge ui/expand ui/column)}
        (div
         {:style (merge ui/row-parted {:padding 8})}
         (span nil)
         (comp-icon
          :arrow-up
          {:font-size 20, :color (hsl 200 80 80), :cursor :pointer}
          (fn [e d! m!]
            (d! :touch-code (:pointer store))
            (when-let [target (js/document.querySelector ".scroll-area")]
              (.. target
                  -firstElementChild
                  (scrollIntoViewIfNeeded (j/obj :behavior "smooth")))))))
        (let [code-data (get-in store [:codes (:pointer store)]), code (:code code-data)]
          (div
           {:style (merge ui/expand ui/center)}
           (div
            {:style ui/row-middle}
            (<> code {:font-size 20, :font-family ui/font-code})
            (=< 8 nil)
            (comp-icon
             :toggle-right
             {:size 20, :color (hsl 0 0 80), :font-size 20, :cursor :pointer}
             (fn [e d! m!] (d! :toggle-barcode (:id code-data)))))
           (if (:barcode? code-data)
             (comp-barcode (>> states :barcode) code code-data)
             (comp-qrcode code))
           (comp-note (>> states :note) code-data)))
        (div
         {:style (merge ui/row-parted {:padding 16})}
         (span nil)
         (comp-confirm
          (>> states :remove)
          {:trigger (comp-i :x-circle 20 (hsl 0 80 70)), :text "Are use sure to remove?"}
          (fn [e d! m!]
            (d! :remove-code (:pointer store))
            (let [new-pointer (first (keys (dissoc (:codes store) (:pointer store))))
                  next-code (get-in store [:codes new-pointer :code])]
              (d! :pointer new-pointer))))))
       (div
        {:style (merge
                 ui/expand
                 ui/center
                 {:font-family ui/font-fancy, :font-size 24, :color (hsl 0 0 80)})}
        (<> "No selection")))
     (comp-sidebar states store)
     (div
      {:style (merge ui/center {:padding 16, :margin :auto})}
      (comp-prompt
       (>> states :create)
       {:trigger (comp-i :plus-square 28 (hsl 200 80 80)),
        :input-style {:font-family ui/font-code},
        :text "Add new code",
        :button-text "Render"}
       (fn [result d! m!] (when-not (string/blank? result) (d! :add-code result)))))
     (when dev? (comp-reel (>> states :reel) reel {}))
     (when dev? (comp-inspect "store" store {:bottom 0})))]))
