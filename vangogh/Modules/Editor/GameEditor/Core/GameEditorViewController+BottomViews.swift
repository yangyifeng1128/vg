///
/// GameEditorViewController
///
/// © 2022 Beijing Mengma Education Technology Co., Ltd
///

import UIKit

extension GameEditorViewController: GameEditorDefaultBottomViewDelegate, GameEditorWillAddSceneBottomViewDelegate, GameEditorSceneBottomViewDelegate {

    func addSceneButtonDidTap() {

        print("[GameEditor] did tap addSceneButton")

        willAddScene = true
        resetBottomView(sceneSelected: false, animated: true)
    }

    func cancelAddingSceneButtonDidTap() {

        print("[GameEditor] did tap cancelAddingSceneButton")

        willAddScene = false
        resetBottomView(sceneSelected: false, animated: true)
    }

    func closeSceneButtonDidTap() {

        print("[GameEditor] did tap closeSceneButton")

        closeScene()
    }

    func deleteSceneButtonDidTap() {

        print("[GameEditor] did tap deleteSceneButton")

        deleteScene()
    }

    func editSceneTitleButtonDidTap() {

        print("[GameEditor] did tap editSceneTitleButton")

        editSceneTitle()
    }

    func sceneTitleLabelDidTap() {

        print("[GameEditor] did tap editSceneTitleButton")

        editSceneTitle()
    }

    func manageTransitionsButtonDidTap() {

        print("[GameEditor] did tap manageTransitionsButton")

        manageTransitions()
    }

    func previewSceneButtonDidTap() {

        print("[GameEditor] did tap previewSceneButton")

        previewScene()
    }

    func editSceneButtonDidTap() {

        print("[GameEditor] did tap editSceneButton")

        editScene()
    }

    func transitionWillDelete(_ transition: MetaTransition, completion: @escaping () -> Void) {

        print("[GameEditor] will delete transition: \(transition)")

        deleteTransition(transition, completion: completion)
    }

    func transitionDidSelect(_ transition: MetaTransition) {

        print("[GameEditor] did select transition: \(transition)")

        let transitionEditorVC = TransitionEditorViewController(gameBundle: gameBundle, transition: transition)
        transitionEditorVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(transitionEditorVC, animated: true)
    }
}

extension GameEditorViewController {

    func resetBottomView(sceneSelected: Bool, animated: Bool) {

        if defaultBottomView != nil {
            defaultBottomView.removeFromSuperview()
            defaultBottomView = nil
        }
        if willAddSceneBottomView != nil {
            willAddSceneBottomView.removeFromSuperview()
            willAddSceneBottomView = nil
        }
        if sceneBottomView != nil {
            sceneBottomView.removeFromSuperview()
            sceneBottomView = nil
        }

        if sceneSelected {

            // 更新底部视图容器

            bottomViewContainer.snp.updateConstraints { make -> Void in
                make.width.equalToSuperview()
                make.height.equalTo(GameEditorSceneBottomView.VC.contentViewHeight)
                make.left.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            if animated {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                    guard let s = self else { return }
                    s.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                view.layoutIfNeeded()
            }

            sceneBottomView = GameEditorSceneBottomView(gameBundle: gameBundle)
            sceneBottomView.delegate = self
            bottomViewContainer.addSubview(sceneBottomView)
            sceneBottomView.snp.makeConstraints { make -> Void in
                make.edges.equalToSuperview()
            }

            // 更新作品板视图容器

            gameboardViewContainer.snp.remakeConstraints { make -> Void in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(bottomViewContainer.snp.top)
            }

            // 更新「当前选中场景」及其相关的穿梭器视图、场景视图

            let sceneView = sceneViewList.first(where: { $0.scene.index == gameBundle.selectedSceneIndex })
            sceneView?.isActive = true
            highlightRelatedTransitionViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的穿梭器视图
            highlightRelatedSceneViews(sceneView: sceneView) // 高亮显示「当前选中场景」相关的场景视图

            // 隐藏「添加场景提示器视图」

            addSceneIndicatorView.isHidden = true

            // 显示操作栏视图，包括「添加穿梭器示意图视图」

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let s = self else { return }
                if let sceneView = sceneView, let thumbImage = MetaThumbManager.shared.loadSceneThumbImage(sceneUUID: sceneView.scene.uuid, gameUUID: s.gameBundle.uuid) {
                    DispatchQueue.main.async {
                        s.addTransitionDiagramView.startSceneView.image = thumbImage
                    }
                } else {
                    DispatchQueue.main.async {
                        s.addTransitionDiagramView.startSceneView.image = .sceneBackgroundThumb
                    }
                }
            }
            addTransitionDiagramView.startSceneIndexLabel.text = gameBundle.selectedSceneIndex.description
            addTransitionDiagramView.isHidden = sceneViewList.count > 1 ? false : true
            let addTransitionDiagramViewLeftOffset: CGFloat = 12
            let addTransitionDiagramViewBottomOffset: CGFloat = AddTransitionDiagramView.VC.height + 12
            addTransitionDiagramView.snp.updateConstraints { make -> Void in
                make.width.equalTo(AddTransitionDiagramView.VC.width)
                make.height.equalTo(AddTransitionDiagramView.VC.height)
                make.left.equalToSuperview().offset(addTransitionDiagramViewLeftOffset)
                make.top.equalTo(bottomViewContainer.safeAreaLayoutGuide.snp.top).offset(-addTransitionDiagramViewBottomOffset)
            }

        } else {

            // 更新底部视图容器

            if !willAddScene {

                bottomViewContainer.snp.updateConstraints { make -> Void in
                    make.width.equalToSuperview()
                    make.height.equalTo(GameEditorDefaultBottomView.VC.contentViewHeight)
                    make.left.equalToSuperview()
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                }
                if animated {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                        guard let s = self else { return }
                        s.view.layoutIfNeeded()
                    }, completion: nil)
                } else {
                    view.layoutIfNeeded()
                }

                defaultBottomView = GameEditorDefaultBottomView()
                defaultBottomView.delegate = self
                bottomViewContainer.addSubview(defaultBottomView)
                defaultBottomView.snp.makeConstraints { make -> Void in
                    make.edges.equalToSuperview()
                }

            } else {

                bottomViewContainer.snp.updateConstraints { make -> Void in
                    make.width.equalToSuperview()
                    make.height.equalTo(GameEditorWillAddSceneBottomView.VC.contentViewHeight)
                    make.left.equalToSuperview()
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                }
                if animated {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                        guard let s = self else { return }
                        s.view.layoutIfNeeded()
                    }, completion: nil)
                } else {
                    view.layoutIfNeeded()
                }

                willAddSceneBottomView = GameEditorWillAddSceneBottomView()
                willAddSceneBottomView.delegate = self
                bottomViewContainer.addSubview(willAddSceneBottomView)
                willAddSceneBottomView.snp.makeConstraints { make -> Void in
                    make.edges.equalToSuperview()
                }
            }

            // 更新作品板视图容器

            gameboardViewContainer.snp.remakeConstraints { make -> Void in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(bottomViewContainer.snp.top)
            }

            // 重置「先前选中场景」及其相关的穿梭器视图

            if let previousSelectedSceneView = sceneViewList.first(where: { $0.scene.index == gameBundle.selectedSceneIndex }) {
                previousSelectedSceneView.isActive = false
                // 取消高亮显示「先前选中场景」相关的穿梭器视图
                unhighlightRelatedTransitionViews(sceneView: previousSelectedSceneView)
                // 取消高亮显示「先前选中场景」相关的场景视图
                unhighlightRelatedSceneViews(sceneView: previousSelectedSceneView)
            }

            // 隐藏「添加场景提示器视图」

            addSceneIndicatorView.isHidden = true

            // 隐藏操作栏视图，包括「添加穿梭器示意图视图」

            addTransitionDiagramView.startSceneIndexLabel.text = ""
            addTransitionDiagramView.isHidden = true

            // 异步保存「当前选中场景」的索引为 0

            gameBundle.selectedSceneIndex = 0
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let s = self else { return }
                MetaGameBundleManager.shared.save(s.gameBundle)
            }
        }
    }
}
