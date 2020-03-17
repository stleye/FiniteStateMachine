//
//  Graph.swift
//  Graph
//
//  Created by Sebastian Tleye on 16/03/2020.
//  Copyright © 2020 HumileAnts. All rights reserved.
//

import Foundation

public struct Graph<T: Hashable> {

    public typealias Element = T

    var description: CustomStringConvertible {
        var result = ""
        for (vertex, edges) in adjacencyDict {
            var edgeString = ""
            for (index, edge) in edges.enumerated() {
                if index != edges.count - 1 {
                    edgeString.append("\(edge.destination), ")
                } else {
                    edgeString.append("\(edge.destination)")
                }
            }
            result.append("\(vertex) ---> [ \(edgeString) ] \n ")
        }
        return result
    }

    private var adjacencyDict: [Vertex: [Edge]] = [:]

    enum EdgeType {
        case directed, undirected
    }

    struct Edge {
        public var source: Vertex
        public var destination: Vertex
        public let weight: Double?
    }

    struct Vertex {
        var data: T
    }

    @discardableResult mutating func createVertex(data: Element) -> Vertex {
        let vertex = Vertex(data: data)

        if adjacencyDict[vertex] == nil {
            adjacencyDict[vertex] = []
        }

        return vertex
    }

    mutating func addDirectedEdge(from source: Vertex, to destination: Vertex, weight: Double?) {
        let edge = Edge(source: source, destination: destination, weight: weight)
        adjacencyDict[source]?.append(edge)
    }

    mutating func addUndirectedEdge(vertices: (Vertex, Vertex), weight: Double?) {
        let (source, destination) = vertices
        addDirectedEdge(from: source, to: destination, weight: weight)
        addDirectedEdge(from: destination, to: source, weight: weight)
    }

    mutating func add(_ type: EdgeType, from source: Vertex, to destination: Vertex, weight: Double?) {
        switch type {
        case .directed:
            addDirectedEdge(from: source, to: destination, weight: weight)
        case .undirected:
            addUndirectedEdge(vertices: (source, destination), weight: weight)
        }
    }

    func weight(from source: Vertex, to destination: Vertex) -> Double? {
        guard let edges = adjacencyDict[source] else {
            return nil
        }
        for edge in edges {
            if edge.destination == destination {
                return edge.weight
            }
        }
        return nil
    }

    func edges(from source: Vertex) -> [Edge]? {
        return adjacencyDict[source]
    }

    func vertices() -> [Vertex] {
        return Array(adjacencyDict.keys)
    }

    func neighbors(of vertex: Vertex) -> [Vertex] {
        return adjacencyDict[vertex]?.map({ $0.destination }) ?? []
    }

}

extension Graph.Edge: Hashable {

    func hash(into hasher: inout Hasher) {
        return hasher.combine("\(source)\(destination)\(weight)")
    }

    static public func ==(lhs: Graph.Edge, rhs: Graph.Edge) -> Bool {
      return lhs.source == rhs.source &&
        lhs.destination == rhs.destination &&
        lhs.weight == rhs.weight
    }

}

extension Graph.Vertex: Hashable, CustomStringConvertible {

    func hash(into hasher: inout Hasher) {
        return hasher.combine("\(data)")
    }

    static public func ==(lhs: Graph.Vertex, rhs: Graph.Vertex) -> Bool { // 2
        return lhs.data == rhs.data
    }

    public var description: String {
        return "\(data)"
    }

}

extension Graph {

    func getComponents() -> [[Vertex]] {
        var result: [[Vertex]] = []
        var visited: [Vertex] = []
        for vertex in self.vertices() where !visited.contains(vertex) {
            let component = self.connected(to: vertex)
            result.append(component)
            visited.append(contentsOf: component)
        }
        return result
    }

    private func connected(to vertex: Vertex) -> [Vertex] {
        var visited: [Vertex] = []
        if !visited.contains(vertex) {
            self.dfsVisit(vertex: vertex, visited: &visited)
        }
        return visited
    }

    private func dfsVisit(vertex: Vertex, visited: inout [Vertex]) {
        visited.append(vertex)
        for neighbor in self.neighbors(of: vertex) {
            if !visited.contains(neighbor) {
                self.dfsVisit(vertex: neighbor, visited: &visited)
            }
        }
    }

}
