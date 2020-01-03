
(ns app.updater
  (:require [respo.cursor :refer [mutate]]
            [app.schema :as schema]
            [medley.core :refer [dissoc-in]]))

(defn updater [store op op-data op-id op-time]
  (case op
    :states (update store :states (mutate op-data))
    :content (assoc store :content op-data)
    :hydrate-storage op-data
    :add-code
      (-> store
          (assoc-in
           [:codes op-id]
           (merge schema/code {:id op-id, :code op-data, :time op-time}))
          (assoc :pointer op-id))
    :touch-code (assoc-in store [:codes op-data :time] op-time)
    :pointer (assoc store :pointer op-data)
    :remove-code (-> store (dissoc-in [:codes op-data]) (assoc :pointer nil))
    :note-code
      (let [code-id (:id op-data), note (:note op-data)]
        (assoc-in store [:codes code-id :note] note))
    store))
