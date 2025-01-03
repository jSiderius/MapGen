extends Node

class_name  PriorityQueue

var heap : Array = []

func insert(item : Variant, priority : float) -> void: 
    heap.append([item, priority])
    heapify_up(len(heap) - 1)

func pop_min() -> Variant: 
    if len(heap) == 0: return null 
    var min_item : Array = heap[0]
    heap[0] = heap[-1]
    heap.pop_back()
    heapify_down(0)
    return min_item[0]
    
func insert_or_update(item : Variant, newPriority : float) -> void: 
    for i in range(len(heap)): 
        if not heap[i][0] == item: continue
        
        var priority : float = heap[i][1]
        heap[i][1] = newPriority
        if newPriority < priority:
            heapify_up(i)
        if newPriority > priority: 
            heapify_down(i)
        return 
    
    insert(item, newPriority)

func insert_or_reduce(item : Variant, newPriority : float) -> void: 
    for i in range(len(heap)): 
        if not heap[i][0] == item: continue
        
        if newPriority < heap[i][1]:
            heap[i][1] = newPriority
            heapify_up(i)
        return 
    
    insert(item, newPriority)

func heapify_up(i : int) -> void: 
    var parent : int = floor((i-1) / 2.0)
    if parent < 0 or heap[i][1] >= heap[parent][1]: return 

    swap(i, parent)
    return heapify_up(parent)


func heapify_down(i : int) -> void: 
    var left : int = 2 * i + 1
    var right : int = 2 * i + 2

    if left < len(heap) and heap[i][1] > heap[left][1]: 
        swap(i, left)
        heapify_down(left)
    elif right < len(heap) and heap[i][1] > heap[right][1]: 
        swap(i, right)
        heapify_down(right)


func swap(index_1 : int, index_2 : int) -> void: 
    var temp = heap[index_1]
    heap[index_1] = heap[index_2]
    heap[index_2] = temp

func is_empty() -> bool: 
    return len(heap) == 0