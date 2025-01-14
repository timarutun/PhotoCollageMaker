//
//  ViewController.swift
//  PhotoCollageMaker
//
//  Created by Timur on 1/1/25.
//

import UIKit

// Struct to store photo and its caption
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
        layout.itemSize = CGSize(width: 100, height: 120) // Increased height for caption
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        view.addSubview(collectionView)
    }

    private func setupNavigationBar() {
        navigationItem.title = "Photo Collage Maker"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
    }

    @objc private func addPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    private func promptForCaption(image: UIImage) {
        let alert = UIAlertController(title: "Add Caption", message: "Enter a caption for the photo", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Caption"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let caption = alert.textFields?.first?.text else { return }
            self?.selectedPhotos.append(Photo(image: image, caption: caption))
            self?.collectionView.reloadData()
        }))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        let photo = selectedPhotos[indexPath.item]

        // Add image view
        let imageView = UIImageView(image: photo.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: 100)
        cell.contentView.addSubview(imageView)

        // Add label for caption
        let label = UILabel(frame: CGRect(x: 0, y: 100, width: cell.contentView.bounds.width, height: 20))
        label.text = photo.caption
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .darkGray
        cell.contentView.addSubview(label)

        return cell
    }
}

// MARK: - UIImagePickerController Delegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true) { [weak self] in
                self?.promptForCaption(image: image)
            }
        } else {
            picker.dismiss(animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

