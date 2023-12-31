import ArgumentParser
import Foundation
import PorscheConnect

extension Porsche {

  struct HonkAndFlash: AsyncParsableCommand {
    // MARK: - Properties

    @OptionGroup()
    var options: Options

    @Argument(help: ArgumentHelp(NSLocalizedString("Your vehicle VIN.", comment: kBlankString)))
    var vin: String

    // MARK: - Lifecycle

    func run() async throws {
      let porscheConnect = PorscheConnect(
        username: options.username,
        password: options.password,
        environment: options.resolvedEnvironment
      )
      await callHonkAndFlash(porscheConnect: porscheConnect, vin: vin)
      dispatchMain()
    }

    // MARK: - Private functions

    private func callHonkAndFlash(porscheConnect: PorscheConnect, vin: String) async {

      do {
        let result = try await porscheConnect.flash(vin: vin, andHonk: true)
        if let remoteCommandAccepted = result.remoteCommandAccepted {
          printRemoteCommandAccepted(remoteCommandAccepted)
        }
        Porsche.HonkAndFlash.exit()
      } catch {
        Porsche.HonkAndFlash.exit(withError: error)
      }
    }

    private func printRemoteCommandAccepted(_ remoteCommandAccepted: RemoteCommandAccepted) {
      print(
        NSLocalizedString(
          "Remote command \"Honk and Flash\" accepted by Porsche API with ID \(remoteCommandAccepted.identifier!)",
          comment: kBlankString))
    }
  }
}
