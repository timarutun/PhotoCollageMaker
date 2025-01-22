//
//  ViewController.swift
//  PhotoCollageMaker
//
//  Created by Timur on 1/1/25.
//

import UIKit

struct Photo {
    let image: UIImage
    let caption: String
}

class MainViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var selectedPhotos: [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupNavigationBar()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
    }

    private func setupNavigationBar() {
        navigationItem.title = "Photo Collage Maker"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto)),
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveCollage))
        ]
    }

    @objc private func addPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func saveCollage() {
        guard !selectedPhotos.isEmpty else {
            let alert = UIAlertController(title: "No Photos", message: "Add photos to create a collage before saving.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let renderer = UIGraphicsImageRenderer(size: collectionView.contentSize)
        let image = renderer.image { context in
            let savedOffset = collectionView.contentOffset
            collectionView.contentOffset = .zero
            collectionView.layer.render(in: context.cgContext)
            collectionView.contentOffset = savedOffset
        }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func imageSaveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alertTitle = (error == nil) ? "Saved!" : "Error"
        let alertMessage = (error == nil) ? "Your collage has been saved to Photos." : "Unable to save collage."
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func calculateCellSize() -> CGSize {
        let itemsPerRow: CGFloat = CGFloat(ceil(sqrt(Double(selectedPhotos.count))))
        let spacing: CGFloat = 10
        let totalSpacing = (itemsPerRow - 1) * spacing
        let cellSize = (view.bounds.width - totalSpacing) / itemsPerRow
        return CGSize(width: cellSize, height: cellSize)
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension MainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        let photo = selectedPhotos[indexPath.item]

        let imageView = UIImageView(image: photo.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = cell.contentView.bounds
        cell.contentView.addSubview(imageView)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateCellSize()
    }
}

// MARK: - UIImagePickerController Delegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedPhotos.append(Photo(image: image, caption: ""))
            collectionView.reloadData()
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


