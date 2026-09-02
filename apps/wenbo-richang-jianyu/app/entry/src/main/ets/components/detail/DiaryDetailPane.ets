import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DiaryEditorSheet } from '../journal/DiaryEditorSheet'
import { JournalHeroImage } from '../journal/JournalHeroImage'
import { CreateFavoriteRequest, JournalItem } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct DiaryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State alreadyFavorited: boolean = false
  @State showEdit: boolean = false
  @State showDelete: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

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
    try {
      this.item = await JournalBizService.findDiary(this.itemId)
      if (this.item !== undefined && AuthService.isLoggedIn()) {
        this.alreadyFavorited = await JournalBizService.hasFavoriteRef(
          `diary:${this.item.id}`,
          this.currentUsername
        )
      } else {
        this.alreadyFavorited = false
      }
    } catch {
      this.item = undefined
    }
    this.loading = false
  }

  private copyText(): void {
    if (this.item === undefined) {
      return
    }
    const text = `${this.item.recordDate}\n${this.item.title}\n${this.item.body}`
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    pasteboard.getSystemPasteboard().setData(data)
    this.showToast('已复制到剪贴板')
  }

  private async handleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined || this.alreadyFavorited) {
      if (this.alreadyFavorited) {
        this.showToast('该笺语已在语句收藏中')
      }
      return
    }
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    req.sourceRefId = `diary:${this.item.id}`
    const created = await JournalBizService.createFavorite(req)
    if (created !== undefined) {
      this.alreadyFavorited = true
      this.showToast('已加入语句收藏')
    } else {
      this.showToast(JournalBizService.lastError.length > 0 ? JournalBizService.lastError : '收藏失败')
    }
  }

  private async confirmDelete(): Promise<void> {
    const ok = await JournalBizService.deleteDiary(this.itemId)
    this.showDelete = false
    if (ok) {
      JournalDetailNav.closeAfterDiaryChange()
    } else {
      this.showToast('删除失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载笺语…' })
      } else if (this.item === undefined) {
        DetailShell({
          title: '我的笺语',
          onClose: (): void => { JournalDetailNav.close() },
          body: (): void => { this.MissingBody() }
        })
      } else {
        DetailShell({
          title: '我的笺语',
          onClose: () => JournalDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }

      if (this.showEdit) {
        DiaryEditorSheet({
          editId: this.itemId,
          onClose: (): void => { this.showEdit = false },
          onSaved: (item: JournalItem): void => {
            this.item = item
            this.showEdit = false
            JournalDetailNav.notifyDiaryChanged()
            this.showToast('已保存修改')
          },
          onRequireAuth: (): void => this.onRequireAuth()
        })
      }

      if (this.showDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('删除这一页？删除后不可恢复。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          AppButton({
            label: '确认删除',
            variant: 'danger',
            onTap: (): void => { void this.confirmDelete() }
          })
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.showDelete = false }
          })
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .zIndex(40)
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
        .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MissingBody() {
    Column() {
      AppEmpty({
        title: '笺语不存在',
        description: '可能已被删除，请返回列表查看',
        actionLabel: '返回',
        onAction: (): void => { JournalDetailNav.close() }
      })
    }
    .width('100%')
    .padding({ top: Theme.space.s8 })
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          JournalHeroImage({
            coverKey: this.item.coverKey,
            fallbackKey: 'hero_morning_coffee',
            heroHeight: 200
          })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(92,107,115,0)', 0], ['rgba(92,107,115,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.recordDate.length > 0 ? this.item.recordDate : '生活笺语')
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

        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '正文', variant: 'plain' }) {
            Text(this.item.body.length > 0 ? this.item.body : '（无正文）')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
          AppButton({
            label: this.alreadyFavorited ? '已在语句收藏' : '加入语句收藏',
            variant: 'secondary',
            disabled: this.alreadyFavorited,
            onTap: (): void => { void this.handleFavorite() }
          })
          AppButton({
            label: '编辑这一页',
            variant: 'secondary',
            onTap: (): void => { this.showEdit = true }
          })
          AppButton({
            label: '复制全文',
            variant: 'ghost',
            onTap: (): void => { this.copyText() }
          })
          AppButton({
            label: '删除这一页',
            variant: 'ghost',
            onTap: (): void => { this.showDelete = true }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
    }
  }
}
