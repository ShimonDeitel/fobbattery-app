import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: FobStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Fob? = nil
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                FobTheme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            row(for: item)
                        }
                        .listRowBackground(FobTheme.card)
                        .accessibilityIdentifier("row_\(item.name)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Key Fob Battery Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                FobFormView(mode: .add) { new in
                    if !store.add(new) {
                        showingPaywall = true
                    }
                }
            }
            .sheet(item: $editingItem) { item in
                FobFormView(mode: .edit(item)) { updated in
                    store.update(updated)
                } onDelete: {
                    store.delete(id: item.id)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(FobTheme.accent)
    }

    @ViewBuilder
    private func row(for item: Fob) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(FobTheme.bodyFont)
                .foregroundColor(FobTheme.textPrimary)
            Text(item.detail)
                .font(FobTheme.captionFont)
                .foregroundColor(FobTheme.textSecondary)
            Text(item.date, style: .date)
                .font(FobTheme.captionFont)
                .foregroundColor(FobTheme.accent)
        }
        .padding(.vertical, 4)
    }
}

enum FobFormMode {
    case add
    case edit(Fob)
}

struct FobFormView: View {
    let mode: FobFormMode
    var onSave: (Fob) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var detail: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Fob name") {
                    TextField("Fob name", text: $name)
                        .accessibilityIdentifier("nameField")
                }
                Section("Battery type") {
                    TextField("Battery type", text: $detail)
                        .accessibilityIdentifier("detailField")
                }
                Section("Replaced date") {
                    DatePicker("Replaced date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("dateField")
                }
                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .accessibilityIdentifier("noteField")
                }
                if case .edit = mode, let onDelete {
                    Section {
                        Button("Delete", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isEditing ? "Edit Fob" : "New Fob")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear(perform: populate)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func populate() {
        if case .edit(let item) = mode {
            name = item.name
            detail = item.detail
            date = item.date
            note = item.note
        }
    }

    private func save() {
        var item: Fob
        if case .edit(let existing) = mode {
            item = existing
        } else {
            item = Fob(name: name, detail: detail, date: date)
        }
        item.name = name
        item.detail = detail
        item.date = date
        item.note = note
        onSave(item)
        dismiss()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(FobStore())
        .environmentObject(PurchaseManager())
}
