import SwiftUI
import ASCollectionView

struct ExampleView: View {
	@State var dataExampleA = (0 ..< 21).map { $0 }
	@State var dataExampleB = (0 ..< 15).map { "ITEM \($0)" }
	
	typealias SectionID = Int
	
	var layout: ASCollectionViewLayout<SectionID> {
		ASCollectionViewLayout { sectionID -> ASCollectionViewLayoutSection in
			switch sectionID {
			case 0:
				return ASCollectionViewLayoutGrid(layoutMode: .adaptive(withMinItemSize: 100), itemSpacing: 5, lineSpacing: 5, itemSize: .absolute(50))
			default:
				return self.customSectionLayout
			}
		}
	}
	
	var body: some View
	{
		ASCollectionView(layout: self.layout) {
			ASCollectionViewSection(id: 0,
									data: dataExampleA,
									dataID: \.self) { item in
										Color.blue
											.overlay(
												Text("\(item)")
										)
			}
			ASCollectionViewSection(id: 1,
									data: dataExampleB,
									dataID: \.self) { item in
										Color.blue
											.overlay(
												Text("Complex layout - \(item)")
										)
			}
			.sectionHeader {
				HStack {
					Text("Section header")
						.padding()
					Spacer()
				}
				.background(Color.yellow)
			}
			.sectionFooter {
				Text("This is a section footer!")
					.padding()
			}
		}
	}
	
	let customSectionLayout = ASCollectionViewLayoutCustomCompositionalSection { (layoutEnvironment, _) -> NSCollectionLayoutSection in
		let isWide = layoutEnvironment.container.effectiveContentSize.width > 500
		let gridBlockSize = layoutEnvironment.container.effectiveContentSize.width / (isWide ? 5 : 3)
		let gridItemInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
		let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(gridBlockSize), heightDimension: .absolute(gridBlockSize))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = gridItemInsets
		let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(gridBlockSize), heightDimension: .absolute(gridBlockSize * 2))
		let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize, subitem: item, count: 2)
		
		let featureItemSize = NSCollectionLayoutSize(widthDimension: .absolute(gridBlockSize * 2), heightDimension: .absolute(gridBlockSize * 2))
		let featureItem = NSCollectionLayoutItem(layoutSize: featureItemSize)
		featureItem.contentInsets = gridItemInsets
		
		let verticalAndFeatureGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(gridBlockSize * 2))
		let verticalAndFeatureGroupA = NSCollectionLayoutGroup.horizontal(layoutSize: verticalAndFeatureGroupSize, subitems: isWide ? [verticalGroup, verticalGroup, featureItem, verticalGroup] : [verticalGroup, featureItem])
		let verticalAndFeatureGroupB = NSCollectionLayoutGroup.horizontal(layoutSize: verticalAndFeatureGroupSize, subitems: isWide ? [verticalGroup, featureItem, verticalGroup, verticalGroup] : [featureItem, verticalGroup])
		
		let rowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(gridBlockSize))
		let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowGroupSize, subitem: item, count: isWide ? 5 : 3)
		
		let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(gridBlockSize * 6))
		let outerGroup = NSCollectionLayoutGroup.vertical(layoutSize: outerGroupSize, subitems: [verticalAndFeatureGroupA, rowGroup, verticalAndFeatureGroupB, rowGroup])
		
		let section = NSCollectionLayoutSection(group: outerGroup)
		
		let supplementarySize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
		let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: supplementarySize,
																			  elementKind: UICollectionView.elementKindSectionHeader,
																			  alignment: .top)
		let footerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: supplementarySize,
																			  elementKind: UICollectionView.elementKindSectionFooter,
																			  alignment: .bottom)
		section.boundarySupplementaryItems = [headerSupplementary, footerSupplementary]
		return section
	}
}
