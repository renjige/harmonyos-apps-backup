import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LayoutConstants } from '../components/design-system/LayoutConstants'
import { DetailShell } from '../components/detail/DetailShell'
import { AtlasItem } from '../data/AtlasCatalog'
import { UserDiscovery } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { ExploreToast } from '../services/ExploreToast'

@Component
export struct FavoritesOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State atlasFavs: AtlasItem[] = []
  @State recordFavs: UserDiscovery[] = []
  @State folderNames: string[] = []
  @State newFolderName: string = ''
  private readonly scrollBottom: number = Theme.space.s10 + LayoutConstants.tabBarInset()

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.atlasFavs = ExplorationStore.favoriteAtlasItems()
    this.recordFavs = ExplorationStore.favoriteDiscoveries()
    const names: string[] = []
    for (const f of ExplorationStore.allFolders()) {
      names.push(f.name)
    }
    this.folderNames = names
  }

  private async createFolder(): Promise<void> {
    if (this.newFolderName.trim().length < 2) {
      ExploreToast.show('收藏夹名称至少 2 个字')
      return
    }
    await ExplorationStore.saveFolder(this.newFolderName.trim())
    this.newFolderName = ''
    this.reload()
    ExploreToast.show('收藏夹已创建')
  }

  build() {
    DetailShell({
        title: '我的收藏',
        onClose: (): void => { ExploreNav.closeFavorites() }
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('收藏夹')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              TextInput({ text: this.newFolderName, placeholder: '新建收藏夹名称' })
                .layoutWeight(1)
                .height(44)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .placeholderColor(Theme.colors().textSecondary)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .padding({ left: 12, right: 12 })
                .onChange((v: string): void => { this.newFolderName = v })
              AppButton({
                label: '创建',
                variant: 'secondary',
                compact: true,
                onTap: (): void => { void this.createFolder() }
              })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            if (this.folderNames.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.folderNames, (name: string) => {
                  Text(name)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                }, (name: string) => `${name}_${this.progressRev}`)
              }
              .width('100%')
            } else {
              Text('暂无收藏夹，输入名称后点「创建」')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }

            Text(`图鉴收藏 · ${this.atlasFavs.length}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (this.atlasFavs.length === 0) {
              AppEmpty({ title: '暂无图鉴收藏', description: '在图鉴详情页点击收藏' })
            } else {
              ForEach(this.atlasFavs, (item: AtlasItem) => {
                Row({ space: Theme.space.s3 }) {
                  Column()
                    .width(40)
                    .height(40)
                    .backgroundColor(item.colorKey)
                    .borderRadius(Theme.radius.sm)
                  Column({ space: 4 }) {
                    Text(item.name)
                      .fontSize(Theme.type.subhead)
                      .fontColor(Theme.colors().textPrimary)
                      .width('100%')
                    Flex({ wrap: FlexWrap.Wrap }) {
                      Text(item.categoryLabel)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandPrimary)
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .backgroundColor(Theme.colors().brandPrimaryContainer)
                        .borderRadius(Theme.radius.pill)
                        .margin({ right: 6, bottom: 4 })
                      ForEach(item.keywords.slice(0, 2), (kw: string) => {
                        Text(kw)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().textSecondary)
                          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                          .backgroundColor(Theme.colors().surfaceSubtle)
                          .borderRadius(Theme.radius.pill)
                          .margin({ right: 6, bottom: 4 })
                      }, (kw: string) => `${item.id}_${kw}`)
                    }
                    .width('100%')
                  }
                  .layoutWeight(1)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => {
                  ExploreNav.closeFavorites()
                  ExploreNav.openAtlasDetail(item.id)
                })
              }, (item: AtlasItem) => `${item.id}_${this.progressRev}`)
            }

            Text(`记录收藏 · ${this.recordFavs.length}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (this.recordFavs.length === 0) {
              AppEmpty({ title: '暂无记录收藏', description: '在探索记录详情页收藏' })
            } else {
              ForEach(this.recordFavs, (d: UserDiscovery) => {
                Row({ space: Theme.space.s3 }) {
                  Column({ space: 4 }) {
                    Text(d.title)
                      .fontSize(Theme.type.subhead)
                      .fontColor(Theme.colors().textPrimary)
                      .width('100%')
                    Text(d.description)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                      .maxLines(1)
                      .width('100%')
                    if (d.tags.length > 0) {
                      Flex({ wrap: FlexWrap.Wrap }) {
                        ForEach(d.tags, (tag: string) => {
                          Text(tag)
                            .fontSize(Theme.type.caption)
                            .fontColor(Theme.colors().brandPrimary)
                            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                            .backgroundColor(Theme.colors().brandPrimaryContainer)
                            .borderRadius(Theme.radius.pill)
                            .margin({ right: 6, bottom: 4 })
                        }, (tag: string) => `${d.id}_${tag}`)
                      }
                      .width('100%')
                    }
                  }
                  .layoutWeight(1)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => {
                  ExploreNav.closeFavorites()
                  ExploreNav.openRecordDetail(d.id)
                })
              }, (d: UserDiscovery) => `${d.id}_${this.progressRev}`)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: this.scrollBottom
          })
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
    }
  }
}
