  //
  //  TasksView.swift
  //  ToDoApp
  //
  //  Created by Jessy Viranaiken on 18/07/2024.
  //

import SwiftUI

struct TasksView: View {
  @Environment(\.presentationMode) private var presentationMode
  @Binding var task_vm: TaskViewModel
  var targetList: ListModel
  
  @State var isPresented_AddNewTaskView = false
  
  var body: some View {
    NavigationStack{
      ZStack{
        Color(.systemGray6)
          .ignoresSafeArea()
        VStack(spacing: 0){
          if task_vm.tasks.isEmpty {
            
            LoadingView(listColor: targetList.fields.pictureColor)
            
         } else if !task_vm.isLoading && task_vm.sortTasks(targetList: self.targetList).isEmpty {
           
            Spacer()
            VStack{
              Text("Aucun rappel dans cette liste.")
                .foregroundStyle(.gray)
                .bold()
              Button(action: { isPresented_AddNewTaskView.toggle() }, label: {
                Text("Ajouter +")
                  .foregroundStyle(.white)
                  .bold()
                  .frame(width: 100, height: 40)
                  .background(ColorsModel().colorFromString(targetList.fields.pictureColor))
                  .clipShape(.rect(cornerRadius: 5))
              })
            }
            Spacer()
           
          } else {
            
            List(task_vm.sortTasks(targetList: self.targetList)){ task in
              HStack{
                VStack(alignment: .leading){
                  HStack{
                    Text(task.fields.name)
                    Text(task.fields.convertPriority(priority: task.fields.priority))
                      .foregroundStyle(ColorsModel().colorFromString(targetList.fields.pictureColor))
                  }
                  if (task.fields.notes != nil) {
                    Text(task.fields.notes!)
                      .font(.subheadline)
                      .foregroundStyle(.gray)
                  }
                  if (task.fields.dateToNotify != nil) {
                    Text(task.fields.formattedDateAndTime()!)
                      .font(.footnote)
                      .foregroundStyle(ColorsModel().colorFromString(targetList.fields.pictureColor))
                  }
                }
                Spacer()
                CheckBoxButton(isCompleted: task.fields.isCompleted ?? false, task: task, pictureColor: targetList.fields.pictureColor)
              }
              .swipeActions{
                Button("Supprimer") {
                  Task{
                    await task_vm.deleteTask(id: task.id!)
                  }
                }
                .tint(.red)
              }
            }
          }
          HStack{
            Button(action: {isPresented_AddNewTaskView.toggle()}, label: {
              Image(systemName: "plus.circle.fill")
                .font(.title)
                .foregroundStyle(ColorsModel().colorFromString(targetList.fields.pictureColor))
              Text("Rappel")
                .font(.title3)
                .foregroundStyle(ColorsModel().colorFromString(targetList.fields.pictureColor))
            })
            .bold()
            Spacer()
          }
          .padding()
          .background(Color(.systemGray6))
          .sheet(isPresented: $isPresented_AddNewTaskView) {
            AddNewTaskView(targetList: targetList, task_vm: self.$task_vm, isPresented: $isPresented_AddNewTaskView, pictureColor: targetList.fields.pictureColor)
              .onDisappear{
                Task{
                  await task_vm.readTasks()
                }
              }
          }
          .navigationBarBackButtonHidden(true)
          .navigationTitle(targetList.fields.title)
        }
        .toolbar{
          ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                // Retourne a la vue parente
              presentationMode.wrappedValue.dismiss()
            }) {
              HStack{
                Image(systemName: "arrow.left")
                Text("Listes")
                  .font(.title3)
              }
              .foregroundStyle(ColorsModel().colorFromString(targetList.fields.pictureColor))
              .bold()
            }
          }
        }
      }
    }
  }
}
