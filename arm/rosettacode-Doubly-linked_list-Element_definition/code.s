/* ARM assembly Raspberry PI  */

/* structure Node Doublylinked List*/
    .struct  0
NDlist_next:                    @ next element
    .struct  NDlist_next + 4 
NDlist_prev:                    @ previous element
    .struct  NDlist_prev + 4 
NDlist_value:                   @ element value or key
    .struct  NDlist_value + 4 
NDlist_fin: