import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { AuthService } from '../services/AuthService'
import { CampBizService } from '../services/CampBizService'
import { CampDetailNav } from '../services/CampDetailNav'
import { CampMedia } from '../services/CampMedia'
import { CatalogItem } from '../models/CampModels'
import { GearRow } from '../components/camp/GearRow'
import { SectionHeader } from '../components/camp/SectionHeader'

@Component
export struct GearPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State loading: boolean = true
  @State filter: string = '全部'
  @State items: CatalogItem[] = []
  @State templates: CatalogItem[] = []
  @State totalG: number = 0
  private cats: string[] = ['全部', '帐篷', '睡眠', '炊具', '照明', '穿着', '工具']

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.templates = await CampBizService.loadTemplates()
    const all = await CampBizService.loadMine('gear')
    this.items = all
    let sum = 0
    for (const g of all) {
      sum += g.weightG
    }
    this.totalG = sum
    this.loading = false
  }

  private visible(): CatalogItem[] {
    if (this.filter === '全部') {
      return this.items
    }
    const out: CatalogItem[] = []
    for (const g of this.items) {
      if (g.category === this.filter) {
        out.push(g)
      }
    }
    return out
  }

  private addGear(): void {
    if (!AuthService.requireAuth('manage_gear')) {
      this.onRequireAuth()
      return
    }
    CampDetailNav.openGearNew()
  }

  build() {
    Column() {
      AppHeader({ title: '装备库', subtitle: `合计 ${(this.totalG / 1000).toFixed(1)} kg` })
      if (this.loading) {
        AppLoading({ label: '清点克数' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.banner_pack'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(60)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(22,51,24,0)', 0.0], ['rgba(22,51,24,0.65)', 1.0]]
                })
              Text('按模板快速搭建装备库')
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F0E8')
                .padding({ left: 16, bottom: 12 })
            }
            .width('100%')
            .height(120)
            .clip(true)
            .borderRadius(Theme.radius.card)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            SectionHeader({ title: '预设模板' })
            Scroll() {
              Row({ space: 10 }) {
                ForEach(this.templates, (t: CatalogItem) => {
                  Column({ space: 6 }) {
                    Image(CampMedia.resource(t.coverKey.length > 0 ? t.coverKey : 'tpl_newbie'))
                      .width(120)
                      .height(88)
                      .borderRadius(Theme.radius.sm)
                      .objectFit(ImageFit.Cover)
                    Text(t.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width(120)
                  }
                  .onClick(() => CampDetailNav.openTemplate(t.id))
                }, (t: CatalogItem) => t.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)

            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.cats, (c: string) => {
                  Text(c)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.filter === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.filter === c ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.filter = c })
                }, (c: string) => c)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)

            if (this.visible().length === 0) {
              AppEmpty({
                title: '还没有装备',
                description: '登录后可新增，或套用模板',
                actionLabel: '新增装备',
                onAction: () => this.addGear()
              })
            } else {
              Column({ space: 8 }) {
                ForEach(this.visible(), (g: CatalogItem) => {
                  GearRow({
                    title: g.title,
                    category: g.category,
                    weightLabel: `${g.weightG} g`,
                    onTap: () => CampDetailNav.openGearEdit(g.id)
                  })
                }, (g: CatalogItem) => g.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            AppButton({ label: '新增装备', onTap: () => this.addGear() })
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
