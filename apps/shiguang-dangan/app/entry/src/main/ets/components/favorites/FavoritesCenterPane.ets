import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { Archive } from '../../models/ArchiveModels'
import { InspirationItem, ImportantMoment, LifePlan, FavoriteFolder } from '../../models/LifeModels'
import { ArchiveStore } from '../../services/ArchiveStore'
import { LifeStore } from '../../services/LifeStore'
import { LifeStorePhase3 } from '../../services/LifeStorePhase3'
import { ArchiveDetailNav } from '../../services/ArchiveDetailNav'

@Component
export struct FavoritesCenterPane {
  @State favTabIndex: number = 0
  @State archives: Archive[] = []
  @State inspirations: InspirationItem[] = []
  @State moments: ImportantMoment[] = []
  @State plans: LifePlan[] = []
  @State folders: FavoriteFolder[] = []
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const allArchives = await ArchiveStore.loadArchives()
    const favArch: Archive[] = []
    for (const a of allArchives) {
      if (a.isFavorite) {
        favArch.push(a)
      }
    }
    this.archives = favArch

    const allInsp = await LifeStore.loadInspirations()
    const favInsp: InspirationItem[] = []
    for (const i of allInsp) {
      if (i.isFavorite) {
        favInsp.push(i)
      }
    }
    this.inspirations = favInsp

    const allMom = await LifeStore.loadMoments()
    const favMom: ImportantMoment[] = []
    for (const m of allMom) {
      if (m.isFavorite) {
        favMom.push(m)
      }
    }
    this.moments = favMom

    const allPlans = await LifeStore.loadPlans()
    const favPlans: LifePlan[] = []
    for (const p of allPlans) {
      if (p.isFavorite) {
        favPlans.push(p)
      }
    }
    this.plans = favPlans
    this.folders = await LifeStorePhase3.loadFavoriteFolders()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s2 }) {
        this.TabChip('档案', 0)
        this.TabChip('灵感', 1)
        this.TabChip('时刻', 2)
        this.TabChip('计划', 3)
        this.TabChip('文件夹', 4)
      }
      .width('100%')

      if (this.favTabIndex === 0) {
        this.ArchiveList()
      } else if (this.favTabIndex === 1) {
        this.InspirationList()
      } else if (this.favTabIndex === 2) {
        this.MomentList()
      } else if (this.favTabIndex === 3) {
        this.PlanList()
      } else {
        this.FolderList()
      }
    }
    .width('100%')
  }

  @Builder
  TabChip(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.favTabIndex === index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.favTabIndex === index ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.favTabIndex = index })
  }

  @Builder
  ArchiveList() {
    if (this.archives.length === 0) {
      AppEmpty({ title: '暂无收藏档案', description: '在档案详情页可标记收藏', actionLabel: '', onAction: (): void => {} })
    } else {
      ForEach(this.archives, (a: Archive) => {
        Text(a.title)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { ArchiveDetailNav.openArchiveDetail(a.id) })
      }, (a: Archive) => a.id)
    }
  }

  @Builder
  InspirationList() {
    if (this.inspirations.length === 0) {
      AppEmpty({ title: '暂无收藏灵感', description: '', actionLabel: '', onAction: (): void => {} })
    } else {
      ForEach(this.inspirations, (i: InspirationItem) => {
        Text(i.text)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
      }, (i: InspirationItem) => i.id)
    }
  }

  @Builder
  MomentList() {
    if (this.moments.length === 0) {
      AppEmpty({ title: '暂无收藏时刻', description: '', actionLabel: '', onAction: (): void => {} })
    } else {
      ForEach(this.moments, (m: ImportantMoment) => {
        Text(m.title)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
      }, (m: ImportantMoment) => m.id)
    }
  }

  @Builder
  PlanList() {
    if (this.plans.length === 0) {
      AppEmpty({ title: '暂无收藏计划', description: '', actionLabel: '', onAction: (): void => {} })
    } else {
      ForEach(this.plans, (p: LifePlan) => {
        Text(p.title)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => {
            AppStorage.setOrCreate('planDetailId', p.id)
          })
      }, (p: LifePlan) => p.id)
    }
  }

  @Builder
  FolderList() {
    if (this.folders.length === 0) {
      AppEmpty({ title: '暂无自定义文件夹', description: '可在后续版本添加', actionLabel: '', onAction: (): void => {} })
    } else {
      ForEach(this.folders, (f: FavoriteFolder) => {
        Text(f.name)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
      }, (f: FavoriteFolder) => f.id)
    }
  }
}
