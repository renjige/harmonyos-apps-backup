import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { RecordEditorSheet } from '../growth/RecordEditorSheet'
import { CreateFavoriteRequest, GrowthRecordItem } from '../../models/GrowthModels'
import { GrowthBizService } from '../../services/GrowthBizService'
import { GrowthMedia } from '../../services/GrowthMedia'
import { GrowthDetailNav } from '../../services/GrowthDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct RecordDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onRecordChanged: () => void = () => {}
  @State item: GrowthRecordItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State showEditor: boolean = false
  @State showDeleteConfirm: boolean = false
  @State deleting: boolean = false

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await GrowthBizService.findRecord(this.itemId)
    this.loading = false
  }

  private async handleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    const u = AppStorage.get<string>('currentUsername')
    req.userId = u !== undefined && u !== null && u.length > 0 ? u : ''
    const created = await GrowthBizService.createFavorite(req)
    if (created !== undefined) {
      this.showToast('已加入成长收藏')
    } else {
      const msg = GrowthBizService.lastError
      this.showToast(msg.length > 0 ? msg : '收藏失败，请稍后重试')
    }
  }

  private async confirmDelete(): Promise<void> {
    if (this.item === undefined || this.deleting) {
      return
    }
    if (!AuthService.requireAuth('create_record')) {
      this.onRequireAuth()
      return
    }
    this.deleting = true
    const uid = AppStorage.get<string>('currentUsername') ?? ''
    const ok = await GrowthBizService.deleteRecord(this.item.id, uid)
    this.deleting = false
    this.showDeleteConfirm = false
    if (ok) {
      this.onRecordChanged()
      GrowthDetailNav.close()
    } else {
      this.showToast(GrowthBizService.lastError.length > 0 ?
        GrowthBizService.lastError : '删除失败')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载成长…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '成长不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '我的成长',
          onClose: (): void => { GrowthDetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
      }

      if (this.showEditor && this.item !== undefined) {
        RecordEditorSheet({
          mode: 'edit',
          editItem: this.item,
          allRecords: [],
          onClose: (): void => { this.showEditor = false },
          onSaved: (): void => {
            this.showEditor = false
            void this.loadItem()
            this.onRecordChanged()
            this.showToast('已保存修改')
          },
          onRequireAuth: (): void => { this.onRequireAuth() }
        })
          .width('100%')
          .height('100%')
          .zIndex(40)
      }

      if (this.showDeleteConfirm) {
        Column() {
          Column({ space: Theme.space.s3 }) {
            Text('确认删除这条记录？')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('删除后无法恢复，请确认。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              AppButton({
                label: '取消',
                variant: 'secondary',
                onTap: (): void => { this.showDeleteConfirm = false }
              }).layoutWeight(1)
              AppButton({
                label: this.deleting ? '删除中…' : '确认删除',
                variant: 'danger',
                onTap: (): void => { void this.confirmDelete() }
              }).layoutWeight(1)
            }
            .width('100%')
          }
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .width('88%')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(15,23,42,0.45)')
        .zIndex(50)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(GrowthMedia.coverMedia(
            this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_latest_inspiration'
          ))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.recordDate.length > 0 ? this.item.recordDate : '成长记录')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.item.summary.length > 0) {
          Column() {
            AppCard({ title: '摘要', variant: 'plain' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '正文', variant: 'plain' }) {
            Text(this.item.body.length > 0 ? this.item.body : '（无正文）')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s2 }) {
          AppButton({
            label: '编辑',
            variant: 'secondary',
            onTap: (): void => { this.showEditor = true }
          }).layoutWeight(1)
          AppButton({
            label: '删除',
            variant: 'danger',
            onTap: (): void => { this.showDeleteConfirm = true }
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '加入成长收藏',
            variant: 'secondary',
            onTap: (): void => { void this.handleFavorite() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
