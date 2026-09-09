import Foundation

/*
 // Original Code from assignemnt
  actor FlightBookingService {
     private var availableSeats: Int = 1
     func reserveSeat(passengerID: String) async -> Bool {
         guard availableSeats > 0 else { return false }
         let paymentApproved = await PaymentGateway.processPayment(for: passengerID)
         guard paymentApproved else { return false }
         availableSeats -= 1
         return true
     }
 }
 
 let bookingService = FlightBookingService()
 async let userA = bookingService.reserveSeat(passengerID: "A")
 async let userB = bookingService.reserveSeat(passengerID: "B")
 let results = await (userA, userB)

 */

/*
 Question 2.1)
 
 When the first request A enters reserveSeat(), availableSeats is 1, so the check passes. It then reaches await while
 waiting for the payment to complete. At this point, A is suspended, but the actor is free to handle another request.
 
 Now request B enters the same method. Since A has not decreased availableSeats yet, B also sees availableSeats = 1, so its
 check also passes. B then reaches await and is suspended.
 
 When A's payment completes, A resumes and decreases availableSeats from 1 to 0.
 
 Then B's payment completes and B also resumes. It continues with availableSeats -= 1, even though there are no seats left.
 This decreases availableSeats from 0 to -1.
 
 So, even though the actor protects availableSeats from being modified by two tasks at the exact same time, the check and
 the modification are separated by await. Because the actor is reentrant at the suspension point, both requests can
 pass the seat check before either one decreases the seat count. This can cause availableSeats go below zero.
 */


/*
 Question 2.2)
 In the below code, used a post-await invariant check to prevent overbooking.
  */

// Dummy PaymentGateway to compile the code
struct PaymentGateway {
    static func processPayment(for passengerID: String) async -> Bool {
        try? await Task.sleep(for: .milliseconds(500))
        return true
    }
}

actor FlightBookingService {
    private var availableSeats: Int = 1
    
    func reserveSeat(passengerID: String) async -> Bool {
        guard availableSeats > 0 else {
            return false
        }
        let paymentApproved = await PaymentGateway.processPayment(for: passengerID)
        guard paymentApproved else {
            return false
        }
        
        // Check available seats again after await to prevent overbooking.
        guard availableSeats > 0 else {
            return false
        }
        
        availableSeats -= 1
        return true
    }
}
