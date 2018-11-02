//
//  TaskflowListViewController.swift
//  Cursor
//
//  Created by Pierre WEHBE on 10/31/18.
//  Copyright © 2018 Atheer. All rights reserved.
//

import UIKit

class TaskflowListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let TASKFLOW_CELL_IDENTIFIER = "TASKFLOW_CELL"
    private let TASKFLOW_VIEWER_SEGUE = "gotoViewer"
    private var taskflow: Taskflow? = nil
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        print("Memory Count: \(FilesManager.shared.taskflows.count)")
        FilesManager.shared.printTaskflows()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TASKFLOW_VIEWER_SEGUE {
            let taskflowViewerVC = segue.destination as! TaskflowViewerViewController
            taskflowViewerVC.currentTaskflow = taskflow
        }
    }
}

extension TaskflowListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilesManager.shared.taskflows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TASKFLOW_CELL_IDENTIFIER, for: indexPath) as! TaskflowCell
        if indexPath.item < FilesManager.shared.taskflows.count {
            cell.bind(taskflow: FilesManager.shared.taskflows[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < FilesManager.shared.taskflows.count {
            print("Selected mem \(FilesManager.shared.taskflows[indexPath.item].name))")
            taskflow = FilesManager.shared.taskflows[indexPath.item]
            performSegue(withIdentifier: TASKFLOW_VIEWER_SEGUE, sender: self)
        }
    }
    
}

