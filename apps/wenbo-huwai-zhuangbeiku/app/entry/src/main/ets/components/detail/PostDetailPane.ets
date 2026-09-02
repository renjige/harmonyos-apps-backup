import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AuthService } from '../../services/AuthService'
import { GearBizService } from '../../services/GearBizService'
import { GearDetailNav } from '../../services/GearDetailNav'
import { GearMedia } from '../../services/GearMedia'
import { CatalogItem, GearWriteRequest } from '../../models/GearModels'
import { DetailShell } from './DetailShell'

@Component
export struct PostDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State comments: CatalogItem[] = []
  @State loading: boolean = true
  @State commentText: string = ''
  @State liked: boolean = false
  @State likeN: number = 0
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await GearBizService.findPath('posts', this.itemId)
    this.likeN = this.item !== undefined ? this.item.likeCount : 0
    this.comments = await GearBizService.loadComments(this.itemId)
    this.loading = false
  }

  private async like(): Promise<void> {
    if (this.liked) {
      return
    }
    this.liked = true
    this.likeN += 1
    await GearBizService.like(this.itemId)
  }

  private async sendComment(): Promise<void> {
    if (!AuthService.requireAuth('comment_post')) {
      this.onRequireAuth()
      return
    }
    if (this.commentText.trim().length === 0) {
      return
    }
    const req = new GearWriteRequest()
    req.title = '评论'
    req.body = this.commentText.trim()
    req.postId = this.itemId
    const ok = await GearBizService.create('comments', req)
    if (ok) {
      this.commentText = ''
      this.comments = await GearBizService.loadComments(this.itemId)
    }
  }

  private async removeMine(): Promise<void> {
    const ok = await GearBizService.remove('posts', this.itemId)
    if (ok) {
      GearDetailNav.close()
    }
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开动态' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '动态', onClose: () => GearDetailNav.close() }) {
        AppEmpty({ title: '动态不存在', actionLabel: '返回', onAction: () => GearDetailNav.close() })
      }
    } else {
      this.Body()
    }
  }

  @Builder
  Body() {
    DetailShell({ title: this.item !== undefined ? this.item.title : '动态', onClose: () => GearDetailNav.close() }) {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(GearMedia.resource(this.item !== undefined && this.item.coverKey.length > 0 ? this.item.coverKey : 'banner_ready'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(90)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,26,26,0)', 0.0], ['rgba(26,26,26,0.82)', 1.0]]
            })
          Text(this.item !== undefined ? this.item.title : '')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F5F5F5')
            .padding(16)
        }
        .width('100%')
        .height(200)
        .clip(true)
        .borderRadius(Theme.radius.card)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

        Text(this.item !== undefined ? this.item.body : '')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: 10 }) {
          AppButton({
            label: this.liked ? `已点赞 · ${this.likeN}` : `点赞 · ${this.likeN}`,
            variant: 'secondary',
            onTap: (): void => { void this.like() }
          })
          TextInput({ text: this.commentText, placeholder: '评论' })
            .onChange((v: string) => { this.commentText = v })
          AppButton({
            label: '发表评论',
            onTap: (): void => { void this.sendComment() }
          })
          ForEach(this.comments, (c: CatalogItem) => {
            Text(`${c.authorName.length > 0 ? c.authorName : '行者'}：${c.body}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }, (c: CatalogItem) => c.id)
          if (this.item !== undefined && this.item.userId === GearBizService.username()) {
            AppButton({
              label: '删除我的动态',
              variant: 'ghost',
              onTap: (): void => { void this.removeMine() }
            })
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
