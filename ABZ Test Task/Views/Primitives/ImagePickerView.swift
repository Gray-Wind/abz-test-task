//
//  ImagePickerView.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 24.06.2025.
//

import SwiftUI

/// The image picker view to be able to show camera dialog or to open photo library
struct ImagePickerView: UIViewControllerRepresentable {

    private var sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    /// Initialize the image picker view
    ///
    /// - Parameter sourceType: The source type to get an image from.
    /// - Parameter onImagePicked: The callback which will be called once image is selected.
    init(
        sourceType: UIImagePickerController.SourceType,
        onImagePicked: @escaping (UIImage) -> Void
    ) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { dismiss() },
            onImagePicked: onImagePicked
        )
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void

        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            onDismiss()
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            onDismiss()
        } 
    }
}
