//
//  ContentView.swift
//  Todos
//
//  Created by gabriel.jeong on 2021/07/14.
//
import ComposableArchitecture
import SwiftUI

struct Todo: Equatable, Identifiable {
    let id: UUID
    var description = ""
    var isComplete  = false
}

struct AppState: Equatable {
    var todos: [Todo] = []
}

enum AppAction {
    //can perform in the UI, such as tapping a button or entering text into a text field.
    case todoCheckboxTapped(index: Int)
    case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {
    // feature needs to do its job, such as API clients, analytics clients, date initializers, schedulers, and more.
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .todoCheckboxTapped(let index):
        state.todos[index].isComplete.toggle()
        return .none
    case .todoTextFieldChanged(let index, let text):
        state.todos[index].description = text
        return .none
    }
}.debug()

struct ContentView: View {
    let store: Store<AppState, AppAction>
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEach(Array(viewStore.state.todos.enumerated()), id: \.element.id) { index, todo in
                        HStack {
                            Button(action: {
                                viewStore.send(.todoCheckboxTapped(index: index))
                            }) {
                                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
                            }.buttonStyle(PlainButtonStyle())
                            
                            TextField("Untitled todo",
                                      text: viewStore.binding(
                                        get: { $0.todos[index].description },
                                        send: { .todoTextFieldChanged(index: index, text: $0) }
                                      ))
                        }
                        
                        .foregroundColor(todo.isComplete ? .gray : nil)
                    }
                }
            }
            .navigationTitle("Title")
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: AppState(todos: [Todo(id: UUID(),
                                                                     description: "Milk",
                                                                     isComplete: false),
                                                                Todo(id: UUID(),
                                                                     description: "Eggs",
                                                                     isComplete: false),
                                                                Todo(id: UUID(),
                                                                     description: "Hand Soap",
                                                                     isComplete: true)]),
                                 reducer: appReducer,
                                 environment: AppEnvironment()))
    }
}
