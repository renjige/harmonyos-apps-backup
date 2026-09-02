import { FavoritesHubPane } from './FavoritesHubPane'
import { ReviewCenterPane } from './ReviewCenterPane'
import { AdvancedFilterSheet } from './AdvancedFilterSheet'
import { ActivityFeedPane } from './ActivityFeedPane'
import { AchievementWallPane } from './AchievementWallPane'
import { MinePanel } from './MinePanel'
import { AdvancedFilter } from '../../models/GrowthModels'

@Component
export struct GrowthOverlayHost {
  @Prop overlayKind: string = ''
  @Prop filter: AdvancedFilter = new AdvancedFilter()
  onClose: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}
  onOpenTool: (kind: string) => void = (_k: string) => {}
  onOpenSettings: () => void = () => {}
  onApplyFilter: (f: AdvancedFilter) => void = (_f: AdvancedFilter) => {}
  onOpenAchievements: () => void = () => {}

  build() {
    if (this.overlayKind === 'favorites') {
      FavoritesHubPane({
        onClose: (): void => { this.onClose() },
        onOpen: (id: string) => { this.onOpen(id) }
      })
    } else if (this.overlayKind === 'review') {
      ReviewCenterPane({
        onClose: (): void => { this.onClose() },
        onOpen: (id: string) => { this.onOpen(id) },
        onOpenTool: (kind: string) => { this.onOpenTool(kind) }
      })
    } else if (this.overlayKind === 'filter') {
      AdvancedFilterSheet({
        filter: this.filter,
        onClose: (): void => { this.onClose() },
        onApply: (f: AdvancedFilter) => { this.onApplyFilter(f) }
      })
    } else if (this.overlayKind === 'activity') {
      ActivityFeedPane({ onClose: (): void => { this.onClose() } })
    } else if (this.overlayKind === 'achievement') {
      AchievementWallPane({ onClose: (): void => { this.onClose() } })
    } else if (this.overlayKind === 'mine') {
      MinePanel({
        onClose: (): void => { this.onClose() },
        onOpenSettings: (): void => { this.onOpenSettings() },
        onOpenAchievements: (): void => { this.onOpenAchievements() }
      })
    }
  }
}
