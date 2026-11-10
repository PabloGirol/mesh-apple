import Foundation
import CoreData
import MeshtasticProtobufs

extension RangeTestConfigEntity {
	convenience init(config: ModuleConfig.RangeTestConfig, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entity(forEntityName: "RangeTestConfigEntity", in: context)!
		self.init(entity: entity, insertInto: context)
		self.sender = Int32(config.sender)
		self.enabled = config.enabled
		self.save = config.save
	}

	func update(with config: ModuleConfig.RangeTestConfig) {
		sender = Int32(config.sender)
		enabled = config.enabled
		save = config.save
	}
}