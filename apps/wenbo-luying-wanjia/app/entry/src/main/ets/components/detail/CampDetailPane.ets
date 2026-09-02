import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AuthService } from '../../services/AuthService'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampMedia } from '../../services/CampMedia'
import { CampWriteRequest, CatalogItem } from '../../models/CampModels'
import { DetailShell } from './DetailShell'

@Component
export struct CampDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCampIdChange') campId: string = ''
  @Prop @Watch('onCampIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State loading: boolean = true
  @State favored: boolean = false
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onCampIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CampBizService.findCamp(this.campId)
    const favs = await CampBizService.loadMine('favorites')
    this.favored = false
    for (const f of favs) {
      if (f.campId === this.campId) {
        this.favored = true
      }
    }
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('favorite_camp')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    if (this.favored) {
      const favs = await CampBizService.loadMine('favorites')
      for (const f of favs) {
        if (f.campId === this.campId) {
          await CampBizService.remove('favorites', f.id)
        }
      }
      this.favored = false
      this.showToast('已取消收藏')
      return
    }
    const body = new CampWriteRequest()
    body.title = this.item.title
    body.campId = this.campId
    body.coverKey = this.item.coverKey
    body.summary = this.item.region
    const ok = await CampBizService.create('favorites', body)
    if (ok) {
      this.favored = true
      this.showToast('已收藏营地')
    }
  }

  private planTrip(): void {
    if (!AuthService.requireAuth('create_trip')) {
      this.onRequireAuth()
      return
    }
    CampDetailNav.openTripNew()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '打开营地档案' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      } else if (this.item === undefined) {
        DetailShell({ title: '营地', onClose: () => CampDetailNav.close() }) {
          AppEmpty({ title: '没有找到营地', description: '换一条档案试试', actionLabel: '返回', onAction: () => CampDetailNav.close() })
        }
      } else {
        this.DetailBody()
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    DetailShell({
      title: this.item !== undefined ? this.item.title : '营地',
      contentKey: this.favored ? 'f1' : 'f0',
      onClose: () => CampDetailNav.close()
    }) {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(CampMedia.resource(this.item !== undefined ? this.item.coverKey : 'hero_camp_night'))
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(120)
            .linearGradient({
              angle: 180,
              colors: [['rgba(22,51,24,0)', 0.0], ['rgba(22,51,24,0.78)', 1.0]]
            })
          Column({ space: 4 }) {
            Text(this.item !== undefined ? this.item.title : '')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F5F0E8')
              .width('100%')
            Text(this.item !== undefined ? `${this.item.region} · ${this.item.campType}` : '')
              .fontSize(Theme.type.footnote)
              .fontColor('#F5F0E8')
          }
          .padding(16)
        }
        .width('100%')
        .height(240)
        .clip(true)
        .borderRadius(Theme.radius.card)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: 8 }) {
          Text('设施')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.item !== undefined ? this.item.facilityText() : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(this.item !== undefined ? this.item.summary : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        Text(this.item !== undefined ? this.item.body : '')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: 10 }) {
          AppButton({ label: '按这座营地规划行程', onTap: () => this.planTrip() })
          AppButton({
            label: this.favored ? '取消收藏' : '收藏营地',
            variant: 'secondary',
            onTap: () => { void this.toggleFav() }
          })
          AppButton({
            label: '写营地笔记',
            variant: 'ghost',
            onTap: () => {
              if (!AuthService.requireAuth('write_note')) {
                this.onRequireAuth()
                return
              }
              CampDetailNav.openNote(this.campId)
            }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
