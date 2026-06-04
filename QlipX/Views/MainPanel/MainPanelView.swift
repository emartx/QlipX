//
//  MainPanelView.swift
//  QlipX
//
//  Created by Seyed Emad Armoun on 15/05/2026.
//

import SwiftUI

struct MainPanelView: View {
    @EnvironmentObject private var store: QlipXStore

    private var title: String {
        String(localized: "app.title", defaultValue: "QlipX")
    }

    private var itemCountLabel: String {
        String(localized: "mainPanel.itemCount", defaultValue: "items")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 22, weight: .semibold))

            PanelControlsView()

            CategoryTabsView()

            ItemListView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            FooterView(itemCount: store.filteredItems.count, itemCountLabel: itemCountLabel)
        }
        .padding(16)
        .frame(
            minWidth: 280,
            idealWidth: 320,
            maxWidth: .infinity,
            minHeight: 360,
            idealHeight: 480,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(.ultraThinMaterial)
        .sheet(isPresented: $store.isExportSheetVisible) {
            ExportSheetView(
                onExportJSON: store.hideExportSheet,
                onExportPlainText: store.hideExportSheet
            )
        }
    }
}

#Preview {
    MainPanelView()
        .environmentObject(
            QlipXStore(
                categories: [
                    Category(
                        name: "Network",
                        colorIndex: 0,
                        items: [
                            Item(content: "192.168.1.10", label: "Local", order: 0),
                            Item(content: "10.0.0.5", label: "Staging", order: 1)
                        ]
                    ),
                    Category(
                        name: "Links",
                        colorIndex: 1,
                        items: [
                            Item(content: "https://example.com/docs", label: "Docs", order: 0)
                        ],
                        isExpanded: false
                    )
                ]
            )
        )
}

#Preview("Empty State") {
    MainPanelView()
        .environmentObject(QlipXStore())
}
