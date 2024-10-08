  //
  //  File.swift
  //  ToDoApp
  //
  //  Created by Jessy Viranaiken on 16/07/2024.
  //  C.R.U.D

import Foundation
import Observation

@Observable class TaskViewModel {
  
  var tasks = [TaskModel]()
  var isLoading = true
  
  private let apiUrl = "https://api.airtable.com/v0/app3Dfn6h8N2Wzzty/Tasks"
  private let apiToken = "patYRbCYvSI0gxfgE.1cf151356d8b06aa3dca4e81334401120accecbc5b7fac6518606be1d6132291"
  
    // Trie des taches
  func sortTasks(targetList: ListModel) -> [TaskModel] {
    return self.tasks.filter { $0.fields.lists[0] == targetList.id }
  }
    // Create
  func createTask(_ task: TaskModel) async {
    
    let url = URL(string: apiUrl)!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
      
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let jsonData = try encoder.encode(task)
      print(jsonData.base64EncodedString())
      request.httpBody = jsonData
      
      let (_, response) = try await URLSession.shared.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
        print("Task created successfully")
      } else {
        print("Failed to create task")
      }
      
    } catch {
      
      print("Failed to encode task: \(error.localizedDescription)")
      
    }
    
    self.isLoading = false
    
  }
    // Read
  @MainActor func readTasks() async {
    
    let url = URL(string: apiUrl)!
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
    
    do {
      
      let (data, _) = try await URLSession.shared.data(for: request)
      
      let decodedData = try JSONDecoder().decode(TasksResponse.self, from: data)
      
      self.tasks = decodedData.records
      
    } catch {
      
      print(error.localizedDescription)
      
    }
    
    self.isLoading = false
    
  }
    // Update
  func updateTask(task: TaskModel) async {
    
    let url = URL(string: "\(apiUrl)/\(task.id!)")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
      // Préparer les champs à mettre à jour
    var fieldsToUpdate: [String: Any] = [:]
    
    if let isCompleted = task.fields.isCompleted {
      fieldsToUpdate["isCompleted"] = isCompleted
    }
    
    let updateBody: [String: Any] = [
      "fields": fieldsToUpdate
    ]
    
    do {

      let jsonData = try JSONSerialization.data(withJSONObject: updateBody, options: [])
      request.httpBody = jsonData
      
      let (_, response) = try await URLSession.shared.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
        print("Task updated successfully!")
      } else {
        print("Failed to update task")
      }
      
    } catch {
      
      print("Failed to encode task: \(error.localizedDescription)")
      
    }
    
    self.isLoading = false
    
  }
    // Delete
  func deleteTask(id: String) async {
    
    self.isLoading = true
    
    let url = URL(string: apiUrl + "/" + id)!
    
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
    
    do {
      
      let (_, response) = try await URLSession.shared.data(for: request)
        // Déballage de l'optionnal afin de vérifier l'existence de la réponse
      if let httpResponse = response as? HTTPURLResponse {
          // Si la requète réussie, statut 200, alors on supprime la tâche localement
        if httpResponse.statusCode == 200 {
          print("Suppression réussie")
          if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
          }
        } else {
          print("Failed to delete task: \(httpResponse.statusCode)")
        }
      }
      
    } catch {
      
      print(error.localizedDescription)
      
    }
    
    self.isLoading = false
    
  }
}
