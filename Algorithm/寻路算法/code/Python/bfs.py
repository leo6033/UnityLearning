'''
@Description: 
@Author: 妄想
@Date: 2020-05-23 19:10:19
@LastEditTime: 2020-05-24 13:07:10
@LastEditors: 妄想
'''

import util

def bfs(graph, start):
    frontier = util.Queue()
    frontier.put(start)
    visited = {}
    visited[start] = True

    while not frontier.empty():
        current = frontier.get()
        print(f"Visiting {current}")
        for next in graph.neighbors(current):
            if next not in visited:
                frontier.put(next)
                visited[next] = True

example_graph = util.SimpleGraph()
example_graph.edges = {
    'A': ['B'],
    'B': ['A', 'C', 'D'],
    'C': ['A'],
    'D': ['E', 'A'],
    'E': ['B']
}

bfs(example_graph, 'A')

g = util.SquareGrid(30, 15)
g.walls = util.DIAGRAM1_WALLS
util.draw_grid(g)

def bfs2(graph, start):
    frontier = util.Queue()
    frontier.put(start)
    came_from = {}
    came_from[start] = None

    while not frontier.empty():
        current = frontier.get()
        for next in graph.neighbors(current):
            if next not in came_from:
                frontier.put(next)
                came_from[next] = current
    
    return came_from

parents = bfs2(g, (8, 7))
util.draw_grid(g, width=2, point_to=parents, start=(8,7))
