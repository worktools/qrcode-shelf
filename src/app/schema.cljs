
(ns app.schema )

(def code {:id nil, :code nil, :note nil, :timestamp nil, :barcode? false})

(def store {:states {}, :codes (do code {}), :pointer nil})
