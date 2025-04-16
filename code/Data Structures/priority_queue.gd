extends Node

class_name  PriorityQueue

var heap : Array = []

func insert(item : Variant, priority : float) -> void: 
    ''' Insert a new item to the PQ according to it's priority '''

    heap.append([item, priority])
    heapify_up(len(heap) - 1)

func pop_min() -> Variant: 
    ''' Pop the item in the queue with the lowest priority '''

    if len(heap) == 0: return null 
    var min_item : Array = heap[0]
    heap[0] = heap[-1]
    heap.pop_back()
    heapify_down(0)
    return min_item[0]
    
func insert_or_update(item : Variant, newPriority : float) -> void: 
    ''' Insert a new item to the PQ according to it's priority, or update it's placement if it already exists '''

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
    ''' Insert a new item to the PQ according to it's priority, or reduce it's placement if it already exists and can be reduced '''

    for i in range(len(heap)): 
        if not heap[i][0] == item: continue
        
        if newPriority < heap[i][1]:
            heap[i][1] = newPriority
            heapify_up(i)
        return 
    
    insert(item, newPriority)

func heapify_up(i : int) -> void: 
    ''' Recursively heapify the item at the passed index up in the PQ until it is at it's correct position '''
    var parent : int = floor((i-1) / 2.0)
    if parent < 0 or heap[i][1] >= heap[parent][1]: return 

    swap(i, parent)
    return heapify_up(parent)


func heapify_down(i : int) -> void: 
    ''' Recursively heapify the item at the passed index down in the PQ until it is at it's correct position '''

    var left : int = 2 * i + 1
    var right : int = 2 * i + 2

    if left < len(heap) and heap[i][1] > heap[left][1]: 
        swap(i, left)
        heapify_down(left)
    elif right < len(heap) and heap[i][1] > heap[right][1]: 
        swap(i, right)
        heapify_down(right)


func swap(index_1 : int, index_2 : int) -> void:
    ''' Swap the items at 2 passed indices in the PQ '''
    var temp = heap[index_1]
    heap[index_1] = heap[index_2]
    heap[index_2] = temp

func is_empty() -> bool: 
    ''' Return a boolean of if the PQ is empty '''
    return len(heap) == 0