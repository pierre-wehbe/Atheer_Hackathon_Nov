import UIKit

class TaskflowCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func bind(taskflow: Taskflow) {
        nameLabel.text = taskflow.name
    }
}
