//
//  FormView.swift
//  ServerDrivenUIDemo
//

import SwiftUI

struct FormView: View {

    @StateObject
    private var viewModel = FormViewModel()

    @State private var showConfirmation = false

    var body: some View {
        Group {
            if let form = viewModel.form {
                let theme = form.theme
                ZStack {
                    Color(hex: theme.backgroundColor)
                        .ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {

                            Text(form.formTitle)
                                .font(.title.bold())
                                .foregroundColor(Color(hex: theme.textColor))

                            ForEach(form.fields, id: \.id) { field in
                                DynamicFieldView(field: field, viewModel: viewModel)
                            }

                            // MARK: Save / Submit button
                            Button {
                                let valid = viewModel.validateAndSubmit()
                                if valid { showConfirmation = true }
                            } label: {
                                Text("Save")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: theme.textColor))
                                    .foregroundColor(Color(hex: theme.backgroundColor))
                                    .cornerRadius(10)
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                    }
                }
                .environment(\.appTheme, theme)
                .alert("Form Submitted ✓", isPresented: $showConfirmation) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.submissionSummary ?? "Saved successfully.")
                }

            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()

            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.loadForm()
        }
    }
}
