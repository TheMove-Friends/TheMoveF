//
//  ChatsTableViewCell.swift
//  TheMove
//
//  Created by User 2 on 3/1/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imagesView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
