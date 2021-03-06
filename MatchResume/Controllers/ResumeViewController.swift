//
//  ResumeViewController.swift
//  MatchResume
//
//  Created by Jorge Mendoza on 12/5/18.
//  Copyright © 2018 Jorge Mendoza. All rights reserved.
//

import Foundation
import UIKit

class ResumeViewController:GenericUITableViewController<EventResume, MatchResumeTableViewCell>{
    
    var matchId:String?
    
    var headerData:TableViewHeaderView.HeaderData?
    
    override func getData() {
        
        guard let id = self.matchId else { return }
        
        Service.shared.getMatchResume(matchId: id) { (response, error) in
            
            if error == nil {
                
                let arr = response?.data ?? []
                
                let unique = Set(arr
                    .filter{ $0.eventID?.code == "#GOL" || $0.eventID?.code == "#REDCARD" || $0.eventID?.code == "#YELLOWCARD" || $0.eventID?.code == "#AGOL" || $0.eventID?.code == "#CHANGE" }
                    .map{ return $0.eventID?.code ?? "" })
                
                for tag in unique {
                    
                    let val:EventResume = self.dataProcess(x: tag)(arr)
                    
                    self.items?.append(val)
                }
                
                self.headerData = TableViewHeaderView.HeaderData.init(homeScore: arr.first?.matchID?.homeTeamScore
                    , awayScore: arr.first?.matchID?.visitorTeamScore
                    , homeName: arr.first?.matchID?.homeTeam?.name
                    , awayName: arr.first?.matchID?.visitorTeam?.name
                    , homeLogo: arr.first?.matchID?.homeTeam?.logoURL
                    , awayLogo: arr.first?.matchID?.visitorTeam?.logoURL)
                
                OperationQueue.main.addOperation { self.customizeTableViewHeader() }
                
               // self.customizeTableViewHeader()

                
                
                //self.items = response?.data
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
            
        }
        
        
    }
    
    override func customizeTableViewHeader() {
        
        let head = TableViewHeaderView()

        //head.createViews()
        
        head.headerData = self.headerData
        
        self.tableView.tableHeaderView = head

        head.frame = CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.width, height: 145.0)
    }
    
}

extension ResumeViewController {
    
    func dataProcess(x: String) -> ([MatchPlayerEvent]) -> EventResume {
        
        return { xs in
            
            let homeId = xs.first?.matchID?.homeTeamID
            
            let awayId = xs.first?.matchID?.visitorTeamID
            
            //Filtered by event Tag
            let arr = xs.filter{ $0.event?.code == x }
            
            let name = arr.first?.event?.name
            
            let url = arr.first?.event?.imgURL
            
            let home = self.processEventTeam(x: homeId ?? 0)(arr)
            
            let away = self.processEventTeam(x: awayId ?? 0)(arr)
            
            return EventResume.init(home: home, away: away, name: name, logo: url)
        }
    }
    
    func processEventTeam(x:Int) -> ([MatchPlayerEvent]) -> Int? {
        return { xs in
            return xs.filter{ $0.teamID == x }.map{ ($0.event?.incrementsBy ?? 0) * 1 }.reduce(0, +)
            
        }
    }
}
