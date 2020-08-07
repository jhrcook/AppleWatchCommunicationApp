//
//  TransferInfoTestingView.swift
//  WatchAppleWatchCommunicationApp Extension
//
//  Created by Joshua on 8/7/20.
//  Copyright © 2020 Joshua Cook. All rights reserved.
//

import SwiftUI

struct TransferInfoTestingView: View, TransferTestingDelegate {
   var communicator: PhoneAndWatchCommunicator
    
    @State var numberOfTransfersRecieved: Int = 0
    @State var numberOfTransfersFinishedSending: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
            Text("Recieved \(numberOfTransfersRecieved) transfer(s)")
            Text("Sent \(numberOfTransfersFinishedSending) transfer(s)")
            Spacer()
            Button("Send transfer") {
                self.communicator.sendTransferTest()
            }
            Spacer()
        }
        .onAppear {
            self.communicator.transferTestingDelegate = self
        }
    }
    
    func transferRecieved() {
        numberOfTransfersRecieved += 1
    }
    
    func transferDidFinish() {
        numberOfTransfersFinishedSending += 1
    }
}

struct TransferInfoTestingView_Previews: PreviewProvider {
    static var previews: some View {
        TransferInfoTestingView(communicator: PhoneAndWatchCommunicator())
    }
}
