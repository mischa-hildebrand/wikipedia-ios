import UIKit

private struct Section {
    let items: [Item]
    let footerTitle: String
}

private struct Item {
    let title: String
    let isOn: Bool
    let controlTag: Int
}

@objc(WMFSearchSettingsViewController)
final class SearchSettingsViewController: SubSettingsViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WMFSettingsTableViewCell.wmf_classNib(), forCellReuseIdentifier: WMFSettingsTableViewCell.identifier)
        title = CommonStrings.searchTitle
    }

    private lazy var sections: [Section] = {
        let showLanguagesOnSearch = Item(title: WMFLocalizedString("settings-language-bar", value: "Show languages on search", comment: "Title in Settings for toggling the display the language bar in the search view"), isOn: UserDefaults.wmf.wmf_showSearchLanguageBar(), controlTag: 1)
        let openAppOnSearchTab = Item(title: WMFLocalizedString("settings-search-open-app-on-search", value: "Open app on Search tab", comment: "Title for setting that allows users to open app on Search tab"), isOn: UserDefaults.wmf.wmf_openAppOnSearchTab, controlTag: 2)
        let items = [showLanguagesOnSearch, openAppOnSearchTab]
        let sections = [Section(items: items, footerTitle: WMFLocalizedString("settings-search-footer-text", value: "Set the app to open to the Search tab instead of the Explore tab", comment: "Footer text for section that allows users to customize certain Search settings"))]
        return sections
    }()

    private func getSection(at index: Int) -> Section {
        assert(sections.indices.contains(index), "Section at index \(index) doesn't exist")
        return sections[index]
    }

    private func getItem(at indexPath: IndexPath) -> Item {
        let items = getSection(at: indexPath.section).items
        assert(items.indices.contains(indexPath.row), "Item at indexPath \(indexPath) doesn't exist")
        return items[indexPath.row]
    }

    // MARK: - Themeable

    override public func apply(theme: Theme) {
        super.apply(theme: theme)
        guard viewIfLoaded != nil else {
            return
        }
        view.backgroundColor = theme.colors.baseBackground
        tableView.backgroundColor = theme.colors.baseBackground
    }
}

extension SearchSettingsViewController {
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = getSection(at: section)
        return section.items.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WMFSettingsTableViewCell.identifier, for: indexPath) as? WMFSettingsTableViewCell else {
            return UITableViewCell()
        }
        let item = getItem(at: indexPath)
        cell.disclosureType = .switch
        cell.tag = item.controlTag
        cell.disclosureSwitch.isOn = item.isOn
        cell.iconName = nil
        cell.title = item.title
        cell.apply(theme)
        cell.delegate = self
        return cell
    }
}

extension SearchSettingsViewController {
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return getSection(at: section).footerTitle
    }
}

extension SearchSettingsViewController: WMFSettingsTableViewCellDelegate {
    public func settingsTableViewCell(_ settingsTableViewCell: WMFSettingsTableViewCell!, didToggleDisclosureSwitch sender: UISwitch!) {
        let controlTag = settingsTableViewCell.tag
        switch controlTag {
        case 1:
            UserDefaults.wmf.wmf_setShowSearchLanguageBar(sender.isOn)
        case 2:
            UserDefaults.wmf.wmf_openAppOnSearchTab = sender.isOn
        default:
            break
        }
    }
}
